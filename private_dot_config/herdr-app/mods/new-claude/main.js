// new-claude: one key for "a fresh Claude in the orchestration folder on the fleet machine".
// Bound as  "cmd-shift-t": "mod.open:new-claude".  It draws nothing: it opens, starts the
// tab and closes itself. The target ({ machine, root, space }) is whatever the fleet mod
// last published in shared state as "fleet.target", so no machine name or path lives here.
import { View, div } from "gpui-kit";
import { props, shared, spaces, run, closeOverlay, notify, checking } from "herdr";

export default class NewClaude extends View {
  init(_props, cx) {
    if (checking()) return;
    const target = shared("fleet.target");
    if (!target?.root) {
      notify({ title: "New Claude", level: "warning", body: "No fleet target yet: show the Fleet panel once so it can publish one." });
    } else {
      const machine = target.machine || null;
      const here = spaces().filter((s) => (s.machine ?? null) === machine);
      const home = here.find((s) => s.name === target.space) ?? here[0] ?? null;
      const start = { folder: target.root, argv: ["claude"] };
      if (home) { run("space.select", { id: home.id }); run("tab.new", { space: home.id, ...start }); }
      else run("space.new", { name: target.space, machine: machine ?? "", ...start });
    }
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay); else run("overlay.close");
  }

  render() { return div(); }
}
