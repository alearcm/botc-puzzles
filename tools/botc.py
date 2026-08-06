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

def load_cards(script: str) -> list[dict]:
    cards = yaml.safe_load((ROOT / "cards" / f"{script}.yaml").read_text())
    assert isinstance(cards, list)
    return cards


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

def night_order_facts(script: str, cards: list[dict]) -> list[str]:
    """Per-script printed sheet order if gathered; else townsquare fallback."""
    ids = {c["id"] for c in cards if not c.get("traveller")}
    no_path = ROOT / "data" / "raw" / "night_orders.json"
    fs = []
    if no_path.exists():
        data = json.loads(no_path.read_text())
        if script in data:
            for kind in ("first", "other"):
                idx = 0
                seen: set[str] = set()
                for entry in data[script][kind]:
                    if entry.isupper():
                        continue  # DUSK/DAWN/MINION_INFO/DEMON_INFO markers
                    if entry in ids and entry not in seen:
                        seen.add(entry)  # snv sheet prints sweetheart/sage twice
                        idx += 1
                        fs.append(f"order({script},{kind},{idx},{entry}).")
            if fs:
                return fs
    # fallback: townsquare global numbers restricted to this script
    roles = json.loads((ROOT / "data" / "raw" / "townsquare_roles.json").read_text())
    by_id = {r["id"]: r for r in roles}
    for kind, key in (("first", "firstNight"), ("other", "otherNight")):
        ordered = sorted(
            (r for r in roles if r["id"] in ids and r.get(key)),
            key=lambda r: r[key],
        )
        for idx, r in enumerate(ordered, 1):
            fs.append(f"order({script},{kind},{idx},{r['id']}).")
    return fs


# ---------------- instances ----------------

@dataclass
class Instance:
    script: str | list[str]
    players: list[str]
    horizon: int = 2
    given: list[str] = field(default_factory=list)
    statements: dict[str, str] = field(default_factory=dict)  # stmt id -> ASP body

    @property
    def scripts(self) -> list[str]:
        return [self.script] if isinstance(self.script, str) else list(self.script)

    def facts(self) -> str:
        out = [f"script({s})." for s in self.scripts]
        for i, p in enumerate(self.players):
            out.append(f"player({p}).")
            out.append(f"seat({p},{i}).")
        for g in self.given:
            g = g.strip().rstrip(".")
            out.append(f"{g}.")
        for sid, body in self.statements.items():
            out.append(f"stmt_true({sid}) :- {body}.")
        return "\n".join(out)


def global_order_facts(scripts: list[str]) -> list[str]:
    """Cross-script sets use the global (townsquare) night order for a
    consistent interleaving; single scripts use their printed sheet."""
    ids = {c["id"] for s in scripts for c in load_cards(s) if not c.get("traveller")}
    roles = json.loads((ROOT / "data" / "raw" / "townsquare_roles.json").read_text())
    fs = []
    for kind, key in (("first", "firstNight"), ("other", "otherNight")):
        ordered = sorted((r for r in roles if r["id"] in ids and r.get(key)),
                         key=lambda r: r[key])
        for idx, r in enumerate(ordered, 1):
            for s in scripts:
                fs.append(f"order({s},{kind},{idx},{r['id']}).")
    return fs


def build_program(inst: Instance) -> str:
    parts = [(ROOT / "engine" / f).read_text() for f in ENGINE_FILES]
    for s in inst.scripts:
        cards = load_cards(s)
        for c in cards:
            parts.append("\n".join(card_facts(c, s)))
    if len(inst.scripts) == 1:
        parts.append("\n".join(night_order_facts(inst.scripts[0],
                                                 load_cards(inst.scripts[0]))))
    else:
        parts.append("\n".join(global_order_facts(inst.scripts)))
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
        script=doc["script"],
        players=doc["players"],
        horizon=doc.get("horizon", 2),
        given=doc.get("given", []),
        statements=doc.get("statements", {}),
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
    their believed character and tokens (the drunk's charade included); evil
    claimants are unconstrained."""
    out = []
    for cl in claims:
        p, char = cl["player"], cl["character"]
        shown = [s.strip().rstrip(".") for s in cl.get("info", [])]
        body = ", ".join([f"initial({p},{char})"] + shown) or f"initial({p},{char})"
        out.append(f"claim_ok({p}) :- {body}.")
        drunk_body = ", ".join(
            [f"initial({p},drunk)", f"believed_init({p},{char})"] + shown)
        out.append(f"claim_ok({p}) :- {drunk_body}.")
        out.append(f"claim_ok({p}) :- initial({p},C), role(C,minion,_).")
        out.append(f"claim_ok({p}) :- initial({p},C), role(C,demon,_).")
        # madness: a mutant claims a townsfolk (fabricated info); a
        # cerenovus-mad player claims their mad character
        out.append(f"claim_ok({p}) :- initial({p},mutant), role({char},townsfolk,_).")
        out.append(f"claim_ok({p}) :- mad({p},{char},_).")
        out.append(f":- not claim_ok({p}).")
    return out


def load_puzzle(path: Path) -> tuple[Instance, dict]:
    doc = yaml.safe_load(Path(path).read_text())
    inst = Instance(
        script=doc["script"],
        players=doc["players"],
        horizon=doc.get("horizon", 2),
        given=doc.get("given", []),
        statements=doc.get("statements", {}),
    )
    roster = {c["id"] for s in inst.scripts for c in load_cards(s)}
    for cl in doc.get("claims", []):
        if cl["character"] not in roster:
            raise ValueError(
                f"claimed character '{cl['character']}' is not on any loaded "
                f"script {inst.scripts} — add the script it comes from "
                f"(silent UNSAT otherwise; see nqt-022)")
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
