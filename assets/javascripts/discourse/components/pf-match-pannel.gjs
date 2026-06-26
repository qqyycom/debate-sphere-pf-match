import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import DateTimeInput from "discourse/components/date-time-input";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import { longDate } from "discourse/lib/formatter";
import { i18n } from "discourse-i18n";

export default class PfMatchPanel extends Component {
  static shouldRender(args) {
    return Boolean(args.model?.pf_match);
  }

  @service dialog;
  @service pfMatchState;

  @tracked selectedDate = null;

  get topic() {
    return this.args.outletArgs?.model ?? null;
  }

  @action
  initializeState() {
    this.pfMatchState.initialize(this.topic);
  }

  get players() {
    return this.pfMatchState.players;
  }

  get judge() {
    return this.pfMatchState.judge;
  }

  get status() {
    return this.pfMatchState.status;
  }

  get startTime() {
    return this.pfMatchState.startTime;
  }

  get formattedStartTime() {
    return longDate(this.startTime);
  }

  get playerUsers() {
    return this.pfMatchState.playerUsers;
  }

  get judgeUser() {
    return this.pfMatchState.judgeUser;
  }

  get isTopicOwner() {
    return this.pfMatchState.isTopicOwner;
  }

  get isRecruiting() {
    return this.pfMatchState.isRecruiting;
  }

  get isReady() {
    return this.pfMatchState.isReady;
  }

  get isScheduled() {
    return this.pfMatchState.isScheduled;
  }

  get isFinished() {
    return this.pfMatchState.isFinished;
  }

  get playersFull() {
    return this.pfMatchState.playersFull;
  }

  get judgePresent() {
    return this.pfMatchState.judgePresent;
  }

  get judgeCount() {
    return this.judgePresent ? 1 : 0;
  }

  get allPositionsFilled() {
    return this.pfMatchState.allPositionsFilled;
  }

  get canSetStartTime() {
    return this.pfMatchState.canSetStartTime;
  }

  get startTimeButtonDisabled() {
    return !this.selectedDate;
  }

  get canFinish() {
    return this.pfMatchState.canFinish;
  }

  get canManageUsers() {
    return this.pfMatchState.canManageUsers;
  }

  get statusLabel() {
    if (this.isRecruiting) {
      return i18n("pf_match.status.recruiting");
    }
    if (this.isReady) {
      return i18n("pf_match.status.ready");
    }
    if (this.isScheduled) {
      return i18n("pf_match.status.scheduled");
    }
    if (this.isFinished) {
      return i18n("pf_match.status.finished");
    }
    return "";
  }

  @action
  onChangeDate(date) {
    this.selectedDate = date;
  }

  @action
  async saveStartTime() {
    if (!this.selectedDate) {
      return;
    }
    await this.pfMatchState.setStartTime(this.selectedDate);
  }

  @action
  async finish() {
    this.dialog.confirm({
      message: i18n("pf_match.messages.confirm_finish"),
      didConfirm: async () => {
        await this.pfMatchState.finish();
      },
    });
  }

  <template>
    {{#if this.topic}}
      <div
        class="pf-match-panel"
        {{didInsert this.initializeState}}
        {{didUpdate this.initializeState this.topic}}
      >
        <h3>{{i18n "pf_match.title"}}</h3>

        <div class="pf-match-summary">
          <div class="pf-match-summary__item pf-match-summary__status">
            <span class="pf-match-summary__label">{{i18n
                "pf_match.labels.status"
              }}</span>
            <span class="pf-match-summary__value">{{this.statusLabel}}</span>
          </div>

          <div class="pf-match-summary__item pf-match-summary__players">
            <span class="pf-match-summary__label">
              {{i18n "pf_match.players"}}
              ({{this.players.length}}/4)
            </span>
            <div class="pf-match-summary__avatars">
              {{#each this.playerUsers as |user|}}
                <UserLink @user={{user}}>
                  {{avatar user imageSize="small"}}
                </UserLink>
              {{else}}
                <span class="pf-match-summary__empty">{{i18n
                    "pf_match.labels.no_players"
                  }}</span>
              {{/each}}
            </div>
          </div>

          <div class="pf-match-summary__item pf-match-summary__judge">
            <span class="pf-match-summary__label">
              {{i18n "pf_match.judge"}}
              ({{this.judgeCount}}/1)
            </span>
            <div class="pf-match-summary__avatars">
              {{#if this.judgeUser}}
                <UserLink @user={{this.judgeUser}}>
                  {{avatar this.judgeUser imageSize="small"}}
                </UserLink>
              {{else}}
                <span class="pf-match-summary__empty">{{i18n
                    "pf_match.labels.no_judge"
                  }}</span>
              {{/if}}
            </div>
          </div>

          {{#if this.startTime}}
            <div class="pf-match-summary__item pf-match-summary__start-time">
              <span class="pf-match-summary__label">{{i18n
                  "pf_match.labels.start_time"
                }}</span>
              <span class="pf-match-summary__value">
                {{this.formattedStartTime}}
              </span>
            </div>
          {{/if}}
        </div>

        {{#if this.canSetStartTime}}
          <div class="pf-match-start-time">
            <h4>{{i18n "pf_match.labels.start_time"}}</h4>
            <DateTimeInput
              @date={{this.selectedDate}}
              @onChange={{this.onChangeDate}}
            />
            <button
              type="button"
              disabled={{this.startTimeButtonDisabled}}
              {{on "click" this.saveStartTime}}
            >
              {{i18n "pf_match.actions.set_start_time"}}
            </button>
          </div>
        {{/if}}

        {{#if this.canFinish}}
          <div class="pf-match-finish">
            <button type="button" {{on "click" this.finish}}>
              {{i18n "pf_match.actions.finish"}}
            </button>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
