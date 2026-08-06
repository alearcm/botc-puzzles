"""Card compiler + solve/check harness.

Cards (cards/*.yaml) are pure data; this module flattens them to ASP facts,
assembles the engine program for a script, and runs queries:

  worlds(instance)   -> enumerate stable models (bounded)
  sat(instance)      -> does any world satisfy the given facts?
  certain(instance, atom) -> does every world contain atom?
"""
from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path

import clingo
import yaml

ROOT = Path(__file__).resolve().parent.parent
ENGINE_FILES = ["core.lp", "death.lp", "info.lp", "mech.lp", "endgame.lp"]


# ---------------- cards ----------------
# Scripts are just character sets. Cards live in per-edition files for
# organisation only; an Instance's character pool is any set of ids, with
# edition names as shorthand for "every character in that edition".

def load_cards(script: str) -> list[dict]:
    cards = yaml.safe_load((ROOT / "cards" / f"{script}.yaml").read_text())
    assert isinstance(cards, list)
    return cards


def card_index() -> dict[str, tuple[dict, str]]:
    """id -> (card, home edition) across every cards/*.yaml."""
    idx: dict[str, tuple[dict, str]] = {}
    for path in sorted((ROOT / "cards").glob("*.yaml")):
        for c in load_cards(path.stem):
            idx[c["id"]] = (c, path.stem)
    return idx


def card_facts(card: dict, script: str) -> list[str]:
    cid, team = card["id"], card["team"]
    fs = [f"role({cid},{team},{script})."]
    if card.get("traveller"):
        fs.append(f"traveller({cid}).")
        return fs
    acts = card.get("acts")
    if acts:
        phase = acts["phase"]
        if acts.get("once"):
            fs.append(f"acts_once({cid},{phase}).")
        else:
            fs.append(f"acts({cid},{phase},x).")
        if acts.get("pick"):
            fs.append(f"acts_pick({cid},{acts['pick']}).")
    learns = card.get("learns")
    if learns:
        fs.append(f"learns({cid},{learns['phase']},{learns['schema']}).")
    status = card.get("status")
    if status:
        fs.append(f"eff_status({cid},{status['kind']},{status['expiry']}).")
    if card.get("kill"):
        fs.append(f"eff_kill({cid},{card['kill']}).")
    for kind in card.get("innate", []):
        fs.append(f"innate_status({cid},{kind}).")
    if card.get("self_misinformed"):
        fs.append(f"self_misinformed({cid},{card['self_misinformed']}).")
    sd = card.get("setup_delta")
    if sd:
        if "choice" in sd:
            a, b = sd["choice"]
            fs.append(f"setup_delta_choice({cid},outsider,{a},{b}).")
        else:
            fs.append(f"setup_delta({cid},outsider,{sd['outsider']}).")
    fs.extend(f"{raw.rstrip('.')}." for raw in card.get("facts", []))
    return fs


# ---------------- night order ----------------
# TPI publishes deviating printed night sheets for the base editions; that
# deviation applies only when the game IS that edition. Any other pool is a
# custom script and uses the script tool's global order.

def sheet_order_facts(script: str, ids: set[str]) -> list[str]:
    """nord facts from an edition's printed sheet, or [] if not gathered."""
    no_path = ROOT / "data" / "raw" / "night_orders.json"
    fs: list[str] = []
    if not no_path.exists():
        return fs
    data = json.loads(no_path.read_text())
    if script not in data:
        return fs
    for kind in ("first", "other"):
        idx = 0
        seen: set[str] = set()
        for entry in data[script][kind]:
            if entry.isupper():
                continue  # DUSK/DAWN/MINION_INFO/DEMON_INFO markers
            if entry in ids and entry not in seen:
                seen.add(entry)  # snv sheet prints sweetheart/sage twice
                idx += 1
                fs.append(f"nord({kind},{idx},{entry}).")
    return fs


def _all_roles() -> list[dict]:
    roles = json.loads((ROOT / "data" / "raw" / "townsquare_roles.json").read_text())
    exp = ROOT / "data" / "raw" / "exp_roles.json"
    if exp.exists():
        roles = roles + json.loads(exp.read_text())
    return roles


def global_order_facts(ids: set[str]) -> list[str]:
    """nord facts from the script-tool global order, restricted to the pool."""
    roles = _all_roles()
    fs = []
    for kind, key in (("first", "firstNight"), ("other", "otherNight")):
        ordered = sorted((r for r in roles if r["id"] in ids and r.get(key)),
                         key=lambda r: r[key])
        for idx, r in enumerate(ordered, 1):
            fs.append(f"nord({kind},{idx},{r['id']}).")
    return fs


# ---------------- instances ----------------

def load_switches() -> list[dict]:
    path = ROOT / "engine" / "switches.yaml"
    return yaml.safe_load(path.read_text()) if path.exists() else []


def switch_facts(settings: dict[str, str] | None) -> list[str]:
    """ASP snippets for the chosen switch settings (defaults unless
    overridden). Unknown switch ids or settings are errors."""
    out = []
    chosen = dict(settings or {})
    for sw in load_switches():
        setting = chosen.pop(sw["id"], sw["default"])
        if setting not in sw["settings"]:
            raise ValueError(f"switch {sw['id']}: unknown setting {setting!r}")
        snippet = sw["settings"][setting].strip()
        if snippet:
            out.append(snippet)
    if chosen:
        raise ValueError(f"unknown switches: {sorted(chosen)}")
    return out


@dataclass
class Instance:
    script: str | list[str] | None = None  # edition shorthand(s) for the pool
    players: list[str] = field(default_factory=list)
    horizon: int = 2
    given: list[str] = field(default_factory=list)
    statements: dict[str, str] = field(default_factory=dict)  # stmt id -> ASP body
    roster: list[str] = field(default_factory=list)  # extra character ids
    switches: dict[str, str] = field(default_factory=dict)  # switch id -> setting

    @property
    def scripts(self) -> list[str]:
        if self.script is None:
            return []
        return [self.script] if isinstance(self.script, str) else list(self.script)

    def pool(self) -> dict[str, tuple[dict, str]]:
        """id -> (card, home edition) for this game's character pool."""
        idx = card_index()
        out: dict[str, tuple[dict, str]] = {}
        for s in self.scripts:
            for c in load_cards(s):
                out[c["id"]] = (c, s)
        for cid in self.roster:
            if cid not in idx:
                raise ValueError(f"unknown character '{cid}' in roster")
            out.setdefault(cid, idx[cid])
        if not out:
            raise ValueError("empty character pool: set script and/or roster")
        return out

    def facts(self) -> str:
        out = []
        for i, p in enumerate(self.players):
            out.append(f"player({p}).")
            out.append(f"seat({p},{i}).")
        for g in self.given:
            g = g.strip().rstrip(".")
            out.append(f"{g}.")
        for sid, body in self.statements.items():
            out.append(f"stmt_true({sid}) :- {body}.")
        return "\n".join(out)


def build_program(inst: Instance) -> str:
    parts = [(ROOT / "engine" / f).read_text() for f in ENGINE_FILES]
    pool = inst.pool()
    for cid, (card, home) in pool.items():
        parts.append("\n".join(card_facts(card, home)))
        parts.append(f"pool({cid}).")
    ids = {cid for cid, (c, _) in pool.items() if not c.get("traveller")}
    # printed-sheet order only when the pool IS exactly one base edition
    nord: list[str] = []
    if not inst.roster and len(inst.scripts) == 1:
        nord = sheet_order_facts(inst.scripts[0], ids)
    if not nord:
        nord = global_order_facts(ids)
    parts.append("\n".join(nord))
    parts.append("\n".join(switch_facts(inst.switches)))
    parts.append(inst.facts())
    return "\n".join(parts)


def make_control(inst: Instance, extra: str = "", models: int = 0) -> clingo.Control:
    ctl = clingo.Control([f"-c horizon={inst.horizon}", str(models)])
    ctl.add("base", [], build_program(inst) + "\n" + extra)
    ctl.ground([("base", [])])
    return ctl


def sat(inst: Instance, extra: str = "") -> bool:
    ctl = make_control(inst, extra, models=1)
    return ctl.solve().satisfiable


def certain(inst: Instance, atom: str) -> bool:
    """True iff every world contains `atom` (and at least one world exists)."""
    if not sat(inst):
        return False
    return not sat(inst, f":- {atom}.")


def worlds(inst: Instance, show: list[str], limit: int = 200) -> list[frozenset[str]]:
    shows = "\n".join(f"#show {s}." for s in show)
    ctl = make_control(inst, "#show.\n" + shows, models=limit)
    out = []
    with ctl.solve(yield_=True) as h:
        for m in h:
            out.append(frozenset(str(a) for a in m.symbols(shown=True)))
    return out


def worlds_proj(inst: Instance, show: list[str], limit: int = 2000,
                extra: str = "") -> tuple[list[frozenset[str]], bool]:
    """DISTINCT projections onto `show` via clingo --project (each projected
    world enumerated once, soundly — no duplicate full models inflating or
    truncating the projection). Returns (worlds, truncated)."""
    shows = "\n".join(f"#show {s}." for s in show)
    ctl = clingo.Control([f"-c horizon={inst.horizon}", "--project", str(limit)])
    ctl.add("base", [], build_program(inst) + "\n#show.\n" + shows + "\n" + extra)
    ctl.ground([("base", [])])
    out = []
    with ctl.solve(yield_=True) as h:
        for m in h:
            out.append(frozenset(str(a) for a in m.symbols(shown=True)))
    return out, len(out) >= limit


def load_fixture(path: Path) -> tuple[Instance, dict]:
    doc = yaml.safe_load(path.read_text())
    inst = Instance(
        script=doc.get("script"),
        players=doc["players"],
        horizon=doc.get("horizon", 2),
        given=doc.get("given", []),
        statements=doc.get("statements", {}),
        roster=doc.get("roster", []),
    )
    return inst, doc


def check_fixture(path: Path) -> tuple[bool, str]:
    inst, doc = load_fixture(path)
    a = doc["assert"]
    if "exists" in a:
        ok = sat(inst) == bool(a["exists"])
        return ok, f"exists={a['exists']}"
    if "certain" in a:
        results = [(atom, certain(inst, atom)) for atom in a["certain"]]
        bad = [atom for atom, r in results if not r]
        return (not bad), f"certain failed: {bad}" if bad else "certain ok"
    if "never" in a:
        bad = [atom for atom in a["never"] if sat(inst, f"holds_never :- {atom}. :- not holds_never.")]
        return (not bad), f"never failed: {bad}" if bad else "never ok"
    raise ValueError(f"fixture {path} has no assertion")


# ---------------- puzzles ----------------

def claim_rules(claims: list[dict], horizon: int) -> list[str]:
    """Puzzle-convention claim semantics. A claim is a STANDING public
    record, not a one-shot statement: it must be covered on EVERY day D of
    the window by one of — truthful believed character (drunk charade
    included), living Mutant fabricating a townsfolk role, cerenovus-mad as
    the claimed character that day, or being evil that day. Players evil at
    the END claim freely, retroactively included ("An Outsider who became
    the Fang Gu may lie about the role they had when they were good", #55).
    An ex-evil player good at the end must be covered like any good player
    (caught on nqt-011: good snake charmers claiming other roles with a
    single final-day madness were spurious demons)."""
    out = []
    days = list(range(1, horizon + 1))
    if claims:
        # evil_day(P,D): alignment DURING day D (night-D changes applied)
        out.append("evil_day(P,D) :- player(P), align(P,evil,D), "
                   "not align_changed(P,D), night(D).")
        out.append("evil_day(P,D) :- player(P), align_change(P,evil,D).")
        out.append("evil_at_end(P) :- evil_day(P,horizon).")
        out.append("alive_day(P,D) :- alive(P,D), not dies_night(P,D).")
        out.append("alive_at_end(P) :- alive_day(P,horizon).")
        # character DURING day D, defined through the final morning
        out.append("char_day(P,C,D) :- char_d(P,C,D), day(D).")
        out.append("char_day(P,C,horizon) :- char(P,C,horizon), "
                   "not char_changed(P,horizon).")
        out.append("char_day(P,C,horizon) :- becomes(P,C,horizon).")
    for cl in claims:
        p, char = cl["player"], cl["character"]
        shown = [s.strip().rstrip(".") for s in cl.get("info", [])]
        for d in days:
            body = ", ".join([f"char_day({p},{char},{d})"] + shown)
            drunk_body = ", ".join(
                [f"char_day({p},drunk,{d})", f"believed_init({p},{char})"]
                + shown)
            out.append(f"ccov({p},{d}) :- {body}.")
            out.append(f"ccov({p},{d}) :- {drunk_body}.")
            # madness compliance belongs to whoever IS the mutant that
            # day (a mutant pit-hagged away loses the cover, a player
            # turned INTO the mutant gains it)
            out.append(f"ccov({p},{d}) :- char_day({p},mutant,{d}), "
                       f"role({char},townsfolk,_), alive_day({p},{d}).")
            out.append(f"ccov({p},{d}) :- mad({p},{char},{d}).")
            out.append(f"ccov({p},{d}) :- evil_day({p},{d}).")
        all_days = ", ".join(f"ccov({p},{d})" for d in days)
        out.append(f"claim_ok({p}) :- {all_days}.")
        # reveal-on-end: madness that ends or changes makes the target
        # reveal they were cerenovus-targeted (NQT convention, ALL players
        # incl. evil/dead) — no claim shows a reveal, so madness persists
        out.append(f":- mad({p},CC,D), night(D2), D2 = D+1, "
                   f"not mad({p},CC,D2).")
        out.append(f":- not claim_ok({p}).")
    return out


def load_puzzle(path: Path) -> tuple[Instance, dict]:
    doc = yaml.safe_load(Path(path).read_text())
    inst = Instance(
        script=doc.get("script"),
        players=doc["players"],
        horizon=doc.get("horizon", 2),
        given=doc.get("given", []),
        statements=doc.get("statements", {}),
        roster=doc.get("roster", []),
    )
    pool = inst.pool()
    for cl in doc.get("claims", []):
        if cl["character"] not in pool:
            raise ValueError(
                f"claimed character '{cl['character']}' is not in the pool "
                f"(scripts {inst.scripts} + roster {inst.roster}) — add it "
                f"to `roster:` (silent UNSAT otherwise; see nqt-022)")
    inst.given.extend(claim_rules(doc.get("claims", []), inst.horizon))
    if doc.get("assume_ongoing", True):
        inst.given.append("assume_ongoing")
    return inst, doc


def solve_puzzle(path: Path, limit: int = 200) -> dict:
    """Demon candidates via SOUND per-player satisfiability queries (immune
    to enumeration truncation); certain atoms via targeted certain() checks
    on the sampled worlds' shared assignment."""
    inst, doc = load_puzzle(path)
    demons = []
    for p in inst.players:
        probe = (f"is_demon_probe :- initial({p},C), role(C,demon,_).\n"
                 f":- not is_demon_probe.")
        if sat(inst, probe):
            demons.append(p)
    ws = worlds(inst, ["initial/2"], limit=limit)
    per_world = []
    shared = None
    for w in ws:
        assignment = {}
        for a in w:
            inner = a[len("initial("):-1]
            p, c = inner.split(",")
            assignment[p] = c
        per_world.append(assignment)
        atoms = frozenset(w)
        shared = atoms if shared is None else (shared & atoms)
    # verify sample-shared atoms as genuinely certain (sound check)
    certain_atoms = [a for a in sorted(shared or []) if certain(inst, a)]
    return {
        "worlds_sampled": len(per_world),
        "truncated": len(per_world) >= limit,
        "demon_candidates": demons,
        "certain": certain_atoms,
        "sample": per_world[:3],
    }


# ---------------- query surface (M3) ----------------

def query_worlds(path: Path, show: list[str], limit: int = 2000) -> dict:
    """All distinct worlds of the observation, projected onto `show`."""
    inst, doc = load_puzzle(path)
    ws, truncated = worlds_proj(inst, show, limit=limit)
    return {"projection": show, "count": len(ws), "truncated": truncated,
            "worlds": [sorted(w) for w in sorted(ws)]}


def query_certain(path: Path, limit: int = 2000) -> dict:
    """Who can you figure out: per-player possible initial characters across
    ALL worlds (sound when not truncated), split into pinned / ambiguous."""
    inst, doc = load_puzzle(path)
    ws, truncated = worlds_proj(inst, ["initial/2"], limit=limit)
    poss: dict[str, set[str]] = {p: set() for p in inst.players}
    for w in ws:
        for a in w:
            p, c = a[len("initial("):-1].split(",")
            poss[p].add(c)
    return {
        "worlds": len(ws), "truncated": truncated,
        "pinned": {p: sorted(cs)[0] for p, cs in poss.items() if len(cs) == 1},
        "ambiguous": {p: sorted(cs) for p, cs in poss.items() if len(cs) > 1},
    }


def query_evilmax(path: Path, night: int, truth: list[str],
                  limit: int = 2000) -> dict:
    """Evil-perspective planning: the demon KNOWS the true grimoire
    (`truth` facts). For each candidate victim realizable in the truth
    world at `night`, count the distinct worlds (initial/2 projection)
    still consistent for the TOWN after that death is announced — evil
    prefers the kill leaving the most worlds standing. The puzzle file
    must be a PREFIX observation (events/claims up to the prior day)."""
    inst, doc = load_puzzle(path)
    tfacts = [t.strip().rstrip(".") for t in truth]

    def extended(extra_given: list[str]) -> Instance:
        return Instance(script=inst.script, players=inst.players,
                        horizon=inst.horizon, given=inst.given + extra_given,
                        statements=inst.statements, roster=inst.roster)

    ranking = {}
    for v in inst.players:
        death = [f":- not announced_dead({v},{night})",
                 f":- announced_dead(P,{night}), P != {v}, player(P)"]
        if not sat(extended(tfacts + death)):
            continue  # not realizable in the true world
        ws, trunc = worlds_proj(extended(death), ["initial/2"], limit=limit)
        ranking[v] = {"worlds": len(ws), "truncated": trunc}
    best = max(ranking, key=lambda v: ranking[v]["worlds"]) if ranking else None
    return {"night": night, "truth": tfacts, "kills": ranking, "best": best}


def query_robust(path: Path) -> dict:
    """Demon candidates under EVERY point of the switch product space:
    which conclusions are robust (hold under all settings) and which are
    setting-dependent. A puzzle whose answer varies across settings it did
    not declare between is ill-posed (DESIGN well-posedness)."""
    import itertools
    inst0, doc = load_puzzle(path)
    sws = load_switches()
    axes = [(sw["id"], sorted(sw["settings"])) for sw in sws]
    per_setting = {}
    for combo in itertools.product(*(vals for _, vals in axes)):
        settings = dict(zip((sid for sid, _ in axes), combo))
        inst, _ = load_puzzle(path)
        inst.switches = settings
        cands = frozenset(
            p for p in inst.players
            if sat(inst, f"idp :- initial({p},C), role(C,demon,_).\n:- not idp."))
        per_setting[",".join(f"{k}={v}" for k, v in settings.items())] = \
            sorted(cands)
    all_sets = [frozenset(v) for v in per_setting.values()]
    robust = sorted(frozenset.intersection(*all_sets)) if all_sets else []
    union = sorted(frozenset.union(*all_sets)) if all_sets else []
    return {"per_setting": per_setting,
            "robust_demon_candidates": robust,
            "union_demon_candidates": union,
            "setting_dependent": union != robust}


def _main() -> None:
    import argparse
    import pprint
    ap = argparse.ArgumentParser(description="BotC world-enumeration queries")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("solve", "worlds", "certain", "count", "evilmax", "robust"):
        sp = sub.add_parser(name)
        sp.add_argument("puzzle", type=Path)
        if name in ("worlds", "count"):
            sp.add_argument("--show", default="initial/2",
                            help="comma-separated projection atoms (name/arity)")
        if name == "evilmax":
            sp.add_argument("--night", type=int, required=True)
            sp.add_argument("--truth", required=True,
                            help="semicolon-separated true-world facts")
        if name != "solve":
            sp.add_argument("--limit", type=int, default=2000)
    args = ap.parse_args()
    if args.cmd == "solve":
        pprint.pprint(solve_puzzle(args.puzzle))
    elif args.cmd == "worlds":
        pprint.pprint(query_worlds(args.puzzle, args.show.split(","),
                                   args.limit))
    elif args.cmd == "count":
        r = query_worlds(args.puzzle, args.show.split(","), args.limit)
        print(f"{r['count']}{'+' if r['truncated'] else ''} distinct worlds "
              f"(projection {r['projection']})")
    elif args.cmd == "certain":
        pprint.pprint(query_certain(args.puzzle, args.limit))
    elif args.cmd == "evilmax":
        pprint.pprint(query_evilmax(args.puzzle, args.night,
                                    args.truth.split(";"), args.limit))
    elif args.cmd == "robust":
        pprint.pprint(query_robust(args.puzzle))


if __name__ == "__main__":
    _main()
