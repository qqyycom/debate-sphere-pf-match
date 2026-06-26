import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class PfMatchPostMenuButton extends Component {
  static shouldRender(args) {
    return Boolean(args.post?.topic?.pf_match) && args.post.post_number !== 1;
  }

  @service pfMatchState;

  get menuActions() {
    return this.pfMatchState.availablePostActions(this.args.post);
  }

  @action
  async perform(menuAction) {
    await menuAction.perform();
  }

  <template>
    {{#each this.menuActions as |menuAction|}}
      <DButton
        class="post-action-menu__pf-match"
        ...attributes
        @action={{fn this.perform menuAction}}
        @icon={{menuAction.icon}}
        @label={{menuAction.label}}
      />
    {{/each}}
  </template>
}
