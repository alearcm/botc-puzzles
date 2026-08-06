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


def global_order_facts(ids: set[str]) -> list[str]:
    """nord facts from the script-tool global order, restricted to the pool."""
    roles = json.loads((ROOT / "data" / "raw" / "townsquare_roles.json").read_text())
    fs = []
    for kind, key in (("first", "firstNight"), ("other", "otherNight")):
        ordered = sorted((r for r in roles if r["id"] in ids and r.get(key)),
                         key=lambda r: r[key])
        for idx, r in enumerate(ordered, 1):
            fs.append(f"nord({kind},{idx},{r['id']}).")
    return fs


# ---------------- instances ----------------

@dataclass
class Instance:
    script: str | list[str] | None = None  # edition shorthand(s) for the pool
    players: list[str] = field(default_factory=list)
    horizon: int = 2
    given: list[str] = field(default_factory=list)
    statements: dict[str, str] = field(default_factory=dict)  # stmt id -> ASP body
    roster: list[str] = field(default_factory=list)  # extra character ids

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

def claim_rules(claims: list[dict]) -> list[str]:
    """Puzzle-convention claim semantics: a good claimant truthfully reports
    their believed character and tokens (the drunk's charade included);
    players who are evil at the end of the observed window claim freely
    ("evil players lie"); an ex-evil player swapped good must claim
    truthfully like any good player."""
    out = []
    if claims:
        # end-state alignment: the final night's change (fang gu jump at
        # horizon, snake charmer swap at horizon) overrides align(_,_,horizon)
        out.append("evil_at_end(P) :- player(P), align(P,evil,horizon), "
                   "not align_changed(P,horizon).")
        out.append("evil_at_end(P) :- player(P), align_change(P,evil,horizon).")
        out.append("alive_at_end(P) :- alive(P,horizon), "
                   "not dies_night(P,horizon).")
    for cl in claims:
        p, char = cl["player"], cl["character"]
        shown = [s.strip().rstrip(".") for s in cl.get("info", [])]
        body = ", ".join([f"initial({p},{char})"] + shown) or f"initial({p},{char})"
        out.append(f"claim_ok({p}) :- {body}.")
        drunk_body = ", ".join(
            [f"initial({p},drunk)", f"believed_init({p},{char})"] + shown)
        out.append(f"claim_ok({p}) :- {drunk_body}.")
        out.append(f"claim_ok({p}) :- evil_at_end({p}).")
        # madness: a LIVING mutant claims a townsfolk (fabricated info); a
        # dead mutant no longer complies and claims truthfully (NQT #55
        # comments); a cerenovus-mad player claims their mad character
        out.append(f"claim_ok({p}) :- initial({p},mutant), "
                   f"role({char},townsfolk,_), alive_at_end({p}).")
        out.append(f"claim_ok({p}) :- mad({p},{char},_).")
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
    inst.given.extend(claim_rules(doc.get("claims", [])))
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


if __name__ == "__main__":
    import pprint
    import sys as _sys
    pprint.pprint(solve_puzzle(Path(_sys.argv[1])))
