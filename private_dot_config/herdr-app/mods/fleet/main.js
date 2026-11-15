// Fleet: what PapaClaude needs from a person, and one click to the session for it.
// Reads the machine-written state under <root>/papaclaude on <machine> (probe.py,
// read-only) and starts or selects tabs in that machine's space.
// props: { machine: "<name from hc machine ls>" | null, root: "<orchestration repo>", space: "<space name>" }
import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, Scrollbar } from "gpui-base";
import { spaces, exec, hc, readTextFile, appHome, theme, run, props, notify, checking } from "herdr";

const REFRESH_MS = 5 * 60 * 1000;

function ago(ms) {
  if (!ms) return "";
  const m = Math.max(0, Math.round((Date.now() - ms) / 60000));
  if (m < 1) return "just now";
  if (m < 60) return `${m}m ago`;
  if (m < 48 * 60) return `${Math.round(m / 60)}h ago`;
  return `${Math.round(m / 1440)}d ago`;
}

export default class Fleet extends View {
  init(_props, cx) {
    this.data = null; this.error = null; this.loading = false; this.loaded = 0; this.filter = "";
    this.input = InputState.new({ placeholder: "Filter campaigns" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value().trim().toLowerCase(); cx.notify(); });
    this.input.on("focus", (_e, cx) => { this.typing = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.typing = false; cx.notify(); });
    // The Run section's argument: an app, host or target handed to a template as its task.
    this.arg = ""; this.hover = null;
    this.argInput = InputState.new({ placeholder: "app, host or target (optional)" });
    this.argInput.on("change", (_e, cx) => { this.arg = this.argInput.value().trim(); cx.notify(); });
    this.argInput.on("focus", (_e, cx) => { this.argTyping = true; cx.notify(); });
    this.argInput.on("blur", (_e, cx) => { this.argTyping = false; cx.notify(); });
    if (checking()) return;
    this.refresh(cx);
    cx.timer.every(REFRESH_MS, (cx) => this.refresh(cx));
  }

  config() {
    const p = props() ?? {};
    return { machine: p.machine || null, root: p.root || "", space: p.space ?? "papaclaude" };
  }

  refresh(cx) {
    if (this.loading) return;
    const { machine, root } = this.config();
    if (!root) { this.error = "no root folder set: give this block props { machine, root } in the layout"; cx.notify(); return; }
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const script = await readTextFile(`${appHome()}/mods/fleet/probe.py`);
        if (!script) throw new Error("mods/fleet/probe.py is missing");
        const r = await exec("python3", ["-c", script, root], { cwd: root, on: machine, timeout: 90000 });
        if (r.code !== 0) throw new Error((r.stderr || r.stdout || `exit ${r.code}`).trim().slice(0, 300));
        this.data = JSON.parse(r.stdout);
        this.error = null; this.loaded = Date.now();
      } catch (e) { this.error = String(e?.message ?? e); }
      finally { this.loading = false; cx.notify(); }
    });
  }

  // The space this panel works in: the named one on the machine, else its first.
  home() {
    const { machine, space } = this.config();
    const here = spaces().filter((s) => (s.machine ?? null) === machine);
    return here.find((s) => s.name === space) ?? here[0] ?? null;
  }

  // Select the tab called `name`, or start Claude in a new one.
  open(name, argv, task) {
    const { machine, root, space } = this.config(), home = this.home();
    const tab = home?.tabs.find((t) => t.name === name);
    if (tab) { run("space.select", { id: home.id }); run("tab.select", { id: tab.id }); return; }
    const start = { folder: root, argv, ...(task ? { task } : {}) };
    if (home) { run("space.select", { id: home.id }); run("tab.new", { space: home.id, name, ...start }); }
    else run("space.new", { name: space, machine: machine ?? "", tab: name, ...start });
  }

  // Select the diff tab for a folder, or open one: a tab whose only pane is the changes-tab mod.
  openChanges(name, cwd) {
    const { machine, space } = this.config(), home = this.home();
    const tab = home?.tabs.find((t) => t.name === name);
    if (tab) { run("space.select", { id: home.id }); run("tab.select", { id: tab.id }); return; }
    const pane = { mod: "changes-tab", props: { cwd, on: machine } };
    if (home) { run("space.select", { id: home.id }); run("tab.new", { space: home.id, name, ...pane }); }
    else notify({ title: "Fleet", body: `No ${space} space on ${machine ?? "this computer"} to open the diff in`, level: "warning" });
  }

  // Start an hc template as a tab: its instructions, then the argument on the next line,
  // which is the first message `hc run <template> <task>` builds. Selects the tab if it is open.
  runTemplate(tpl, cx) {
    const arg = this.arg;
    this.open(arg ? `${tpl.name} ${arg}` : tpl.name, ["claude"], arg ? `${tpl.body}\n${arg}` : tpl.body);
    this.arg = ""; this.argInput.set_value(""); cx.notify();
  }

  // Type `claude --resume <session>` into each terminal that lost its Claude session.
  // hc keys presses keys one by one; hc send would wrap the text in a tag a shell rejects.
  restoreTabs(list, cx) {
    if (this.restoring) return;
    const { machine } = this.config();
    const keys = (text) => [...text].map((c) => (c === " " ? "space" : c));
    this.restoring = true; cx.notify();
    cx.spawn(async (cx) => {
      let done = 0;
      const failed = [];
      for (const r of list) {
        const address = machine ? `${machine}/${r.terminal}` : r.terminal;
        try {
          // Only letters, digits and / . - are known to type cleanly; skip the cd otherwise.
          if (/^[a-z0-9/.-]+$/.test(r.cwd)) {
            const cd = await hc(["keys", address, ...keys(`cd ${r.cwd}`), "enter"]);
            if (cd.code !== 0) throw new Error(cd.stderr || "cd failed");
          }
          const go = await hc(["keys", address, ...keys(`claude --resume ${r.session}`), "enter"]);
          if (go.code !== 0) throw new Error(go.stderr || "keys failed");
          done++;
        } catch (e) { failed.push(r.where || r.terminal); }
      }
      notify({ title: "Fleet", level: failed.length ? "warning" : "success",
        body: failed.length ? `Resumed ${done}; could not reach: ${failed.join(", ")}` : `Resumed ${done} Claude session${done === 1 ? "" : "s"}` });
      this.restoring = false;
      this.refresh(cx);
    });
  }

  openCampaign(c) {
    if (c.session) this.open(c.name, ["claude", "--resume", c.session]);
    else this.open(c.name, ["claude"], `/campaign ${c.name}`);
  }

  section(t, title, right) {
    return h_flex().h(26).flex_none().px(14).gap(8).items_center().text_size(10.5).text_color(t.dim)
      .child(div().font_semibold().child(title.toUpperCase())).child(div().flex_1()).when(Boolean(right), (e) => e.child(div().child(right)));
  }

  // One clickable summary line: a colored count, a label, a detail, and what clicking does.
  summary(t, id, { count, color, label, detail, tab, onClick }) {
    const home = this.home(), live = home?.tabs.find((x) => x.name === tab);
    return h_flex().id(id).mx(6).px(8).h(44).flex_none().gap(10).items_center().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click(onClick)
      .child(div().w(34).flex_none().text_right().text_size(18).font_semibold().text_color(color).child(String(count)))
      .child(v_flex().flex_1().min_w(0)
        .child(div().truncate().child(label))
        .child(div().truncate().text_size(11).text_color(t.dim).child(detail)))
      .child(div().flex_none().text_size(11).text_color(live ? t.accent : t.dim).child(live ? "open" : "start"));
  }

  render(cx) {
    const t = theme(), d = this.data, { machine } = this.config(), home = this.home();
    let root = v_flex().id("fleet").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background)
      .border_1().border_color(t.border).text_color(t.foreground).text_size(13);
    const header = h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
      .child(div().font_semibold().child("Fleet"))
      .child(div().px(5).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).child(machine ?? "this computer"))
      .child(div().flex_1())
      .child(div().id("fleet-refresh").px(6).py(2).rounded(5).text_size(11).text_color(t.dim).cursor_pointer()
        .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.refresh(cx))
        .child(this.loading ? "refreshing…" : this.loaded ? `↻ ${ago(this.loaded)}` : "↻ refresh"));
    root = root.child(header);
    if (this.error) root = root.child(div().px(14).py(8).text_size(11).text_color(t.ansi1).child(`Could not read fleet state: ${this.error}`));
    if (!d) return root.child(div().p(14).text_color(t.dim).child(this.loading ? "Reading fleet state…" : this.error ? "" : "No data yet"));

    // Alerts
    const a = d.alerts ?? {};
    root = root.child(this.section(t, "Attention"));
    if (a.error) root = root.child(div().px(14).py(4).text_size(11).text_color(t.ansi1).child(`alert digest: ${a.error}`));
    else {
      const bad = (a.sources ?? []).filter((s) => s.status !== "ok").map((s) => `${s.name} ${s.status}`);
      const open = (a.sources ?? []).filter((s) => s.open > 0).map((s) => `${s.name} ${s.open}`).join(" · ");
      const made = a.generated ? ago(Date.parse(a.generated)) : "unknown time";
      root = root.child(this.summary(t, "fleet-alerts", {
        count: a.open ?? 0, color: bad.length ? t.ansi1 : a.open > 0 ? t.blocked : t.done, tab: "alerts",
        label: `open alerts of ${a.count ?? 0} in the digest${a.partial ? " (partial)" : ""}`,
        detail: bad.length ? `source problem: ${bad.join(", ")}` : `${open || "none still open"} · digest ${made}`,
        onClick: () => this.open("alerts", ["claude"], "/alerts"),
      }));
    }
    // Lost sessions: shown only when a terminal is back to a bare shell with a session to resume.
    const lost = d.restorable ?? [];
    if (d.restorable_error) root = root.child(div().px(14).py(4).text_size(11).text_color(t.ansi1).child(`restore check: ${d.restorable_error}`));
    if (lost.length) root = root.child(h_flex().id("fleet-restore").mx(6).px(8).h(44).flex_none().gap(10).items_center().rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.restoreTabs(lost, cx))
      .child(div().w(34).flex_none().text_right().text_size(18).font_semibold().text_color(t.blocked).child(String(lost.length)))
      .child(v_flex().flex_1().min_w(0)
        .child(div().truncate().child(lost.length === 1 ? "tab lost its Claude session" : "tabs lost their Claude session"))
        .child(div().truncate().text_size(11).text_color(t.dim).child(lost.map((r) => (r.where || r.terminal).split(" / ").pop()).join(", "))))
      .child(div().flex_none().text_size(11).text_color(t.accent).child(this.restoring ? "resuming…" : "resume")));
    // CVEs
    const c = d.cve ?? {};
    if (c.error) root = root.child(div().px(14).py(4).text_size(11).text_color(t.ansi1).child(`pwn-watch: ${c.error}`));
    else root = root.child(this.summary(t, "fleet-cve", {
      count: c.incidents ?? 0, color: t.muted, tab: "cve",
      label: "incidents tracked by pwn-watch",
      detail: `state updated ${ago((c.mtime ?? 0) * 1000)}`,
      onClick: () => this.open("cve", ["claude"], "/cve"),
    }));

    // Run: the hc templates on the machine, as chips. The box above them is the task.
    const tpls = d.templates ?? [];
    if (tpls.length) {
      const shown = tpls.find((x) => x.name === this.hover);
      root = root.child(this.section(t, "Run", `${tpls.length} templates`));
      root = root.child(div().id("fleet-arg").mx(10).mb(6).h(30).flex_none().px(10).flex().items_center().rounded(8).border_1()
        .border_color(this.argTyping ? t.accent : t.border).cursor_text()
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .child(Input.new(this.argInput).h_full().text_size(12).text_color(t.foreground)));
      root = root.child(h_flex().flex_wrap().flex_none().mx(10).gap(6).children(tpls.map((x) => {
        const name = this.arg ? `${x.name} ${this.arg}` : x.name, live = home?.tabs.find((y) => y.name === name);
        return div().id(`run-${x.name}`).px(8).h(24).flex().items_center().rounded(6).border_1().text_size(12).cursor_pointer()
          .border_color(live ? t.accent : t.border).text_color(live ? t.accent : t.foreground)
          .hover((s) => s.bg(t.hover)).on_hover((on, cx) => { this.hover = on ? x.name : this.hover === x.name ? null : this.hover; cx.notify(); })
          .on_click((_e, cx) => this.runTemplate(x, cx)).child(x.name);
      })));
      root = root.child(div().mx(14).mt(4).h(34).flex_none().overflow_hidden().whitespace_normal().text_size(11).text_color(t.dim)
        .child(shown ? shown.description : "Click a name to start it in a new tab. Hover for what it does."));
    }

    // Uncommitted work: the orchestration repo itself, then stack worktrees that are not clean.
    // A row opens (or selects) a view-only diff tab for that folder.
    const wt = d.worktrees ?? [], { root: base } = this.config();
    const work = (id, label, state, color, cwd, tabName) => {
      const live = home?.tabs.find((y) => y.name === tabName);
      return h_flex().id(id).mx(6).px(8).h(26).flex_none().gap(8).items_center().rounded(7).text_size(12).cursor_pointer()
        .hover((s) => s.bg(t.hover)).on_click(() => this.openChanges(tabName, cwd))
        .child(div().w(6).h(6).rounded(3).flex_none().bg(color))
        .child(div().flex_1().min_w(0).truncate().child(label))
        .child(div().flex_none().text_size(11).text_color(live ? t.accent : t.dim).child(live ? "open" : state));
    };
    root = root.child(this.section(t, "Uncommitted work", wt.length ? `${wt.length} worktrees` : null));
    const n = d.root_dirty;
    root = root.child(work("fleet-root", base, n == null ? "unknown" : n ? `${n} files` : "clean", n ? t.blocked : t.dim, base, "changes"));
    if (d.worktrees_error) root = root.child(div().px(14).py(2).text_size(11).text_color(t.ansi1).child(d.worktrees_error));
    root = root.children(wt.slice(0, 8).map((w) => work(`wt-${w.path}`, w.path, w.ahead > 0 ? `${w.state} · ${w.ahead} unpushed` : w.state,
      t.blocked, `${base}/temp/worktrees/${w.path}`, `Δ ${w.path}`)));
    if (wt.length > 8) root = root.child(div().px(14).text_size(11).text_color(t.dim).child(`and ${wt.length - 8} more`));

    // Campaigns
    const all = d.campaigns ?? [], f = this.filter;
    const shown = f ? all.filter((x) => x.name.toLowerCase().includes(f) || x.description.toLowerCase().includes(f)) : all;
    const active = all.filter((x) => x.status === "active").length;
    root = root.child(this.section(t, "Campaigns", `${active} active · ${all.length - active} deferred`));
    root = root.child(div().id("fleet-filter").mx(10).mb(6).h(30).flex_none().px(10).flex().items_center().rounded(8).border_1()
      .border_color(this.typing ? t.accent : t.border).cursor_text()
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .child(Input.new(this.input).h_full().text_size(12).text_color(t.foreground)));
    root = root.child(div().flex_1().min_h(0).relative()
      .child(v_flex().id("fleet-campaigns").absolute().inset_0().overflow_y_scroll().px(6).pb(6).children(shown.map((x) => {
        const tab = home?.tabs.find((y) => y.name === x.name);
        const dot = tab?.status ? t[tab.status] : x.status === "deferred" ? t.dim : t.muted;
        return h_flex().id(`camp-${x.name}`).h(40).flex_none().px(8).gap(8).items_center().rounded(7).cursor_pointer()
          .when(Boolean(tab?.active && home?.active), (e) => e.bg(t.selected)).hover((s) => s.bg(t.hover))
          .on_click(() => this.openCampaign(x))
          .child(div().w(6).h(6).rounded(3).flex_none().bg(dot))
          .child(v_flex().flex_1().min_w(0)
            .child(div().truncate().text_color(x.status === "deferred" ? t.muted : t.foreground).child(x.name))
            .child(div().truncate().text_size(11).text_color(t.dim).child(x.description || "no description")))
          .child(div().flex_none().text_size(11).text_color(tab ? t.accent : t.dim).child(tab ? "open" : x.session ? "resume" : ago(x.mtime * 1000)));
      })).when(!shown.length, (e) => e.child(div().p(8).text_color(t.dim).child(f ? "No campaign matches" : "No open campaigns"))))
      .child(Scrollbar.vertical("fleet-campaigns").absolute().inset_0()));
    return root;
  }
}
