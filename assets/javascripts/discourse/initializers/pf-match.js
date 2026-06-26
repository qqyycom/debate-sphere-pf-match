import { apiInitializer } from "discourse/lib/api";
import PfMatchPanel from "../components/pf-match-pannel";
import PfMatchPostMenuButton from "../components/pf-match-post-menu-button";

export default apiInitializer((api) => {
  api.renderInOutlet("topic-above-post-stream", PfMatchPanel);

  api.registerValueTransformer(
    "post-menu-buttons",
    ({ value: dag, context: { firstButtonKey } }) => {
      dag.add("pf-match-post-menu", PfMatchPostMenuButton, {
        before: firstButtonKey,
      });
    }
  );
});
