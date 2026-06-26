import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class PfMatchState extends Service {
  @service currentUser;

  @tracked topic = null;
  @tracked players = [];
  @tracked judge = null;
  @tracked status = "recruiting";
  @tracked startTime = null;
  @tracked playerUsers = [];
  @tracked judgeUser = null;

  initialize(topic) {
    if (!topic) {
      this.topic = null;
      this.applyState({});
      return;
    }

    if (this.topic?.id === topic.id) {
      return;
    }

    this.topic = topic;
    this.applyState(topic.pf_match || {});
  }

  applyState(result) {
    const pfMatch = result?.pf_match || result || {};

    this.players = (pfMatch.players || []).map(Number);
    this.judge = pfMatch.judge ?? null;
    this.status = pfMatch.status || "recruiting";
    this.startTime = pfMatch.start_time || null;

    if (pfMatch.users) {
      this.playerUsers = pfMatch.users.players || [];
      this.judgeUser = pfMatch.users.judge || null;
    }
  }

  get isTopicOwner() {
    return this.currentUser?.id === this.topic?.user_id;
  }

  get isRecruiting() {
    return this.status === "recruiting";
  }

  get isReady() {
    return this.status === "ready";
  }

  get isScheduled() {
    return this.status === "scheduled";
  }

  get isFinished() {
    return this.status === "finished";
  }

  get playersFull() {
    return this.players.length >= 4;
  }

  get judgePresent() {
    return this.judge != null && this.judge !== "";
  }

  get allPositionsFilled() {
    return this.playersFull && this.judgePresent;
  }

  get canSetStartTime() {
    return this.isTopicOwner && this.isReady;
  }

  get canFinish() {
    return this.isTopicOwner && this.isScheduled;
  }

  get canManageUsers() {
    return this.isTopicOwner && (this.isRecruiting || this.isReady);
  }

  stateForTopic(topic) {
    if (this.topic?.id === topic?.id) {
      return {
        players: this.players,
        judge: this.judge,
        status: this.status,
      };
    }

    const pfMatch = topic?.pf_match || {};
    return {
      players: (pfMatch.players || []).map(Number),
      judge: pfMatch.judge ?? null,
      status: pfMatch.status || "recruiting",
    };
  }

  isPlayer(userId) {
    return this.players.includes(Number(userId));
  }

  isJudge(userId) {
    return parseInt(this.judge, 10) === Number(userId);
  }

  isPlayerInState(state, userId) {
    return state.players.includes(Number(userId));
  }

  isJudgeInState(state, userId) {
    return parseInt(state.judge, 10) === Number(userId);
  }

  canManagePost(post, state = this.stateForTopic(post?.topic)) {
    return (
      this.currentUser?.id === post?.topic?.user_id &&
      ["recruiting", "ready"].includes(state.status) &&
      post.post_number !== 1 &&
      post.user?.id
    );
  }

  availablePostActions(post) {
    const state = this.stateForTopic(post?.topic);

    if (!this.canManagePost(post, state)) {
      return [];
    }

    const userId = post.user.id;

    if (this.isPlayerInState(state, userId)) {
      return [
        {
          id: "remove-player",
          label: "pf_match.actions.remove_player",
          icon: "user-minus",
          perform: () => this.removePlayer(post.topic, userId),
        },
      ];
    }

    if (this.isJudgeInState(state, userId)) {
      return [
        {
          id: "remove-judge",
          label: "pf_match.actions.remove_judge",
          icon: "user-minus",
          perform: () => this.removeJudge(post.topic),
        },
      ];
    }

    const actions = [];

    if (state.players.length < 4) {
      actions.push({
        id: "add-player",
        label: "pf_match.actions.add_player",
        icon: "user-plus",
        perform: () => this.addPlayer(post.topic, userId),
      });
    }

    if (state.judge == null || state.judge === "") {
      actions.push({
        id: "set-judge",
        label: "pf_match.actions.set_judge",
        icon: "user-check",
        perform: () => this.setJudge(post.topic, userId),
      });
    }

    return actions;
  }

  async addPlayer(topic, userId) {
    await this.#post(topic, "/pf-match/add-player", { user_id: userId });
  }

  async removePlayer(topic, userId) {
    await this.#post(topic, "/pf-match/remove-player", { user_id: userId });
  }

  async setJudge(topic, userId) {
    await this.#post(topic, "/pf-match/set-judge", { user_id: userId });
  }

  async removeJudge(topic) {
    await this.#post(topic, "/pf-match/remove-judge");
  }

  async setStartTime(date) {
    if (!date) {
      return;
    }

    await this.#post(this.topic, "/pf-match/set-start-time", {
      start_time: date.toISOString(),
    });
  }

  async finish() {
    await this.#post(this.topic, "/pf-match/finish");
  }

  async #post(topic, url, data = {}) {
    try {
      const result = await ajax(url, {
        type: "POST",
        data: { topic_id: topic.id, ...data },
      });
      this.topic = topic;
      this.applyState(result);
    } catch (error) {
      popupAjaxError(error);
    }
  }
}
