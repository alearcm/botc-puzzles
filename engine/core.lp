%%% core.lp — time, seating, setup, bag, schedule, acting, statuses, trace.
%%% Instance supplies: player/1, seat/2 (0-indexed), script/1, horizon via
%%% #const, plus observation facts. Cards supply role/3 and mechanic facts
%%% (see docs/CARDS.md). Everything else is derived or chosen here.

#const horizon = 3.

night(1..horizon).
day(T) :- night(T), T < horizon.          % day T follows night T

% ---------- seating ----------
nplayers(N) :- N = #count{ P : player(P) }.
succ_seat(P,Q) :- seat(P,I), seat(Q,J), nplayers(N), J = (I+1) \ N.
neigh(P,Q) :- succ_seat(P,Q).
neigh(P,Q) :- succ_seat(Q,P).

% alive neighbours at night T (skipping dead seats around the circle)
% next living clockwise: walk successor seats
% neighbours are computed over APPARENT life: a fake-dead Zombuul registers
% dead to everything, including neighbour-based abilities.
reach_cw(P,Q,T) :- succ_seat(P,Q), night(T).
reach_cw(P,R,T) :- reach_cw(P,Q,T), not app_alive(Q,T), succ_seat(Q,R), R != P.
alive_neigh_cw(P,Q,T) :- reach_cw(P,Q,T), app_alive(Q,T),
    #false : reach_cw(P,R,T), app_alive(R,T), before_cw(P,R,Q).
% before_cw(P,R,Q): walking clockwise from P, R comes strictly before Q
before_cw(P,R,Q) :- walk(P,R,N1), walk(P,Q,N2), N1 < N2.
walk(P,Q,1) :- succ_seat(P,Q).
walk(P,R,N+1) :- walk(P,Q,N), succ_seat(Q,R), N < 15, R != P.
alive_neighbor(P,Q,T) :- alive_neigh_cw(P,Q,T).
alive_neighbor(P,Q,T) :- alive_neigh_ccw(P,Q,T).

% ---------- positional life state (site clock for deaths) ----------
% A reader at night-order position I sees deaths that resolved at earlier
% positions: an Empath acting after the Imp reads the circle with tonight's
% victim already dead (NQT #31). life_pos/2 declares the positions where a
% neighbour circle is actually read (emitted by the info layer).
app_alive_at(Q,T,I) :- app_alive(Q,T), life_pos(T,I), not died_by(Q,T,I).
died_by(Q,T,I) :- death_event(Q,T), death_idx(Q,T,J), life_pos(T,I), J < I.
reach_cw_at(P,Q,T,I) :- succ_seat(P,Q), life_pos(T,I).
reach_cw_at(P,R,T,I) :- reach_cw_at(P,Q,T,I), not app_alive_at(Q,T,I),
                        succ_seat(Q,R), R != P.
alive_neigh_cw_at(P,Q,T,I) :- reach_cw_at(P,Q,T,I), app_alive_at(Q,T,I),
    #false : reach_cw_at(P,R,T,I), app_alive_at(R,T,I), before_cw(P,R,Q).
reach_ccw_at(P,Q,T,I) :- succ_seat(Q,P), life_pos(T,I).
reach_ccw_at(P,R,T,I) :- reach_ccw_at(P,Q,T,I), not app_alive_at(Q,T,I),
                         succ_seat(R,Q), R != P.
alive_neigh_ccw_at(P,Q,T,I) :- reach_ccw_at(P,Q,T,I), app_alive_at(Q,T,I),
    #false : reach_ccw_at(P,R,T,I), app_alive_at(R,T,I), before_ccw(P,R,Q).
alive_neighbor_at(P,Q,T,I) :- alive_neigh_cw_at(P,Q,T,I).
alive_neighbor_at(P,Q,T,I) :- alive_neigh_ccw_at(P,Q,T,I).
reach_ccw(P,Q,T) :- succ_seat(Q,P), night(T).
reach_ccw(P,R,T) :- reach_ccw(P,Q,T), not app_alive(Q,T), succ_seat(R,Q), R != P.
alive_neigh_ccw(P,Q,T) :- reach_ccw(P,Q,T), app_alive(Q,T),
    #false : reach_ccw(P,R,T), app_alive(R,T), before_ccw(P,R,Q).
before_ccw(P,R,Q) :- walkc(P,R,N1), walkc(P,Q,N2), N1 < N2.
walkc(P,Q,1) :- succ_seat(Q,P).
walkc(P,R,N+1) :- walkc(P,Q,N), succ_seat(R,Q), N < 15, R != P.

% ---------- roster ----------
% pool(Char): the character pool of this game, emitted by the compiler.
% Scripts are just character sets — rules never key on an edition. role/3
% carries the character's home edition purely as provenance.
in_pool(C) :- pool(C), not traveller(C).
team_of(C,Team) :- role(C,Team,_).
good_team(townsfolk). good_team(outsider).
evil_team(minion). evil_team(demon).

% ---------- setup counts ----------
base_counts(5,3,0,1).  base_counts(6,3,1,1).  base_counts(7,5,0,1).
base_counts(8,5,1,1).  base_counts(9,5,2,1).  base_counts(10,7,0,2).
base_counts(11,7,1,2). base_counts(12,7,2,2). base_counts(13,9,0,3).
base_counts(14,9,1,3). base_counts(15,9,2,3).

% ---------- bag ----------
1 { initial(P,C) : in_pool(C) } 1 :- player(P).
% no duplicate characters (homebrew puzzles may lift this via dup_ok/1)
:- initial(P,C), initial(Q,C), P < Q, not dup_ok(C).

in_play(C) :- initial(_,C).

% setup deltas: setup_delta(C, outsider, D) fixed; setup_delta_choice(C, outsider, D1, D2)
chosen_delta(C,K,D) :- setup_delta(C,K,D), in_play(C).
1 { chosen_delta(C,K,D1) ; chosen_delta(C,K,D2) } 1 :-
    setup_delta_choice(C,K,D1,D2), in_play(C).
total_delta(K,S) :- S = #sum{ D,C : chosen_delta(C,K,D) }, kind(K).
kind(outsider).

tf_count(K)  :- K = #count{ P : initial(P,C), team_of(C,townsfolk) }.
out_count(K) :- K = #count{ P : initial(P,C), team_of(C,outsider) }.
min_count(K) :- K = #count{ P : initial(P,C), team_of(C,minion) }.
dem_count(K) :- K = #count{ P : initial(P,C), team_of(C,demon) }.

:- nplayers(N), base_counts(N,_,O,_), total_delta(outsider,DO),
   out_count(K), K != O + DO.
:- nplayers(N), base_counts(N,_,_,M), min_count(K), K != M.
:- dem_count(K), K != 1.
:- nplayers(N), base_counts(N,TF,O,M), total_delta(outsider,DO),
   tf_count(K), K != TF - DO.   % outsider deltas trade against townsfolk

% ---------- alignment ----------
align(P,good,1) :- initial(P,C), team_of(C,Team), good_team(Team).
align(P,evil,1) :- initial(P,C), team_of(C,Team), evil_team(Team).
% inertia + explicit changes (mech layer emits align_change/3)
align(P,A,T+1) :- align(P,A,T), night(T+1), not align_changed(P,T).
align(P,A,T+1) :- align_change(P,A,T), night(T+1).
align_changed(P,T) :- align_change(P,_,T).

% ---------- character over time ----------
char(P,C,1) :- initial(P,C).
char(P,C,T+1) :- char(P,C,T), night(T+1), not char_changed(P,T).
char(P,C,T+1) :- becomes(P,C,T), night(T+1).
char(P,C,T+1) :- becomes_day(P,C,T), night(T+1).
char_changed(P,T) :- becomes(P,_,T).
char_changed(P,T) :- becomes_day(P,_,T).
:- char(P,C1,T), char(P,C2,T), C1 < C2.   % one character per player per night

% character DURING day D: night-D changes (star pass, snake charmer...) have
% materialised by dawn; day-triggered changes (SW takeover on execution) are
% becomes_day and do not retro-apply to their own day.
char_d(P,C,D) :- char(P,C,D), day(D), not night_changed(P,D).
char_d(P,C,D) :- becomes(P,C,D), day(D).
night_changed(P,D) :- becomes(P,_,D), day(D).

% ---------- believed character (self-misinformation) ----------
% self_misinformed(C, BelievedTeam): drunk thinks townsfolk, lunatic thinks demon
1 { believed_init(P,B) : role(B,BT,_), in_pool(B), B != C } 1 :-
    initial(P,C), self_misinformed(C,BT), role(B2,BT,_).
believed_init(P,C) :- initial(P,C), not self_misinformed(C,_).
% (believed char is static in base scripts; philosopher et al. handled in mech)

% shadow ability: the believed character's schedule runs as theater
shadow(P,B,T) :- believed_init(P,B), initial(P,C), self_misinformed(C,_),
                 night(T).

% ---------- night schedule ----------
% nord(first|other, Idx, Char) from the compiler: the printed edition sheet
% when the pool IS exactly a base edition (TPI's documented deviation),
% otherwise the script-tool global order restricted to the pool.
sched(C,1,I) :- nord(first,I,C).
sched(C,T,I) :- nord(other,I,C), night(T), T > 1.

% ---------- ability acquisition time (relative schedules) ----------
ability_start(P,C,1) :- initial(P,C).
ability_start(P,C,T+1) :- becomes(P,C,T), night(T+1).
% asched: schedule extended with a pseudo-position for abilities gained
% mid-game whose card has no other-night entry (first-night-only abilities
% fire on the first night the ability is held).
asched(C,T,I) :- sched(C,T,I).
% philosopher-gained abilities run at the philosopher's own position
asched(C,T,I) :- phil_gains(_,C,T), sched(philosopher,T,I).
phil_sched(C,T) :- phil_gains(_,C,T).
asched(C,T,98) :- ability_start(P,C,T), T > 1, not sched(C,T,_),
                  not phil_sched(C,T).

% hpos: the acting position of a SPECIFIC holder of an ability (asched is
% char-level and conflates a real holder with a philosopher copyist)
hpos(P,C,T,I) :- has_ability(P,C,T), sched(C,T,I), not phil_held(P,C).
hpos(P,C,T,I) :- has_ability(P,C,T), phil_gains(P,C,_),
                 sched(philosopher,T,I).
hpos(P,C,T,98) :- has_ability(P,C,T), ability_start(P,C,T0), T0 > 1,
                  night(T), not sched(C,T,_), not phil_held(P,C).
phil_held(P,C) :- phil_gains(P,C,_).

% ---------- ability possession ----------
% dead players lose abilities, unless kept (persists_dead from mech layer)
has_ability(P,C,T) :- char(P,C,T), alive(P,T).
has_ability(P,C,T) :- char(P,C,T), not alive(P,T), persists_dead(P,C,T).

% ---------- acting ----------
% acts(C, first|other|each, PickSpec) from cards.
due(C,P,T) :- acts(C,first,_), sched(C,1,_), T=1, has_ability(P,C,T),
              ability_start(P,C,1).
% first-night-only abilities gained mid-game fire on their first held night
due(C,P,T) :- acts(C,first,_), ability_start(P,C,T), T>1, has_ability(P,C,T).
due(C,P,T) :- acts(C,other,_), sched(C,T,_), T>1, has_ability(P,C,T).
due(C,P,T) :- acts(C,each,_),  asched(C,T,_),     has_ability(P,C,T).
% once-per-game night powers: used marker constrains
due_once(C,P,T) :- acts_once(C,PhaseSel), sched(C,T,_), has_ability(P,C,T),
                   phase_ok(PhaseSel,T).
phase_ok(first,1). phase_ok(other,T) :- night(T), T>1.
phase_ok(each,T) :- night(T).
0 { uses_once(P,C,T) } 1 :- due_once(C,P,T), not blocked_act(P,T).
:- uses_once(P,C,T), uses_once(P,C,T2), T < T2.

acting(P,C,T) :- due(C,P,T), not blocked_act(P,T).
acting(P,C,T) :- uses_once(P,C,T).
% blocked_act: exorcist on demon, zombuul off-night, etc. (mech layer)

% shadow acting (theater): believed character's schedule, scope S1 default:
% alive charades always run; on-death triggers run (delta: charade scope)
shadow_acting(P,B,T) :- shadow(P,B,T), acts(B,first,_), sched(B,1,_), T=1,
                        alive(P,T).
shadow_acting(P,B,T) :- shadow(P,B,T), acts(B,other,_), sched(B,T,_), T>1,
                        alive(P,T).
shadow_acting(P,B,T) :- shadow(P,B,T), acts(B,each,_), sched(B,T,_),
                        alive(P,T).

% ---------- picks ----------
% pick specs: p1_any, p1_alive, p1_alive_not_self, p1_not_self, p2_alive,
% p2_players, p1_and_char, char_only
1 { picked(P,C,T,Q) : player(Q) } 1 :-
    acting(P,C,T), acts_pick(C,p1_any).
1 { picked(P,C,T,Q) : app_alive(Q,T) } 1 :-
    acting(P,C,T), acts_pick(C,p1_alive).
1 { picked(P,C,T,Q) : app_alive(Q,T), Q != P } 1 :-
    acting(P,C,T), acts_pick(C,p1_alive_not_self).
1 { picked(P,C,T,Q) : player(Q), Q != P } 1 :-
    acting(P,C,T), acts_pick(C,p1_not_self).
1 { picked2(P,C,T,Q1,Q2) : app_alive(Q1,T), app_alive(Q2,T), Q1 < Q2 } 1 :-
    acting(P,C,T), acts_pick(C,p2_alive).
1 { picked2(P,C,T,Q1,Q2) : app_alive(Q1,T), app_alive(Q2,T), Q1 < Q2,
                           Q1 != P, Q2 != P } 1 :-
    acting(P,C,T), acts_pick(C,p2_alive_not_self).
% no_repeat_pick(C): may not choose the same player two nights running
:- no_repeat_pick(C), picked(P,C,T,Q), picked(P,C,T-1,Q).

% pick legality as integrity constraints (instance-supplied picks included)
:- acts_pick(C,p1_alive), picked(P,C,T,Q), not app_alive(Q,T).
:- acts_pick(C,p1_alive_not_self), picked(P,C,T,Q), not app_alive(Q,T).
:- acts_pick(C,p1_alive_not_self), picked(P,C,T,P).
:- acts_pick(C,p1_not_self), picked(P,C,T,P).
:- acts_pick(C,p2_alive), picked2(P,C,T,Q,_), not app_alive(Q,T).
:- acts_pick(C,p2_alive), picked2(P,C,T,_,Q), not app_alive(Q,T).
:- acts_pick(C,p2_alive_not_self), picked2(P,C,T,Q,_), not app_alive(Q,T).
:- acts_pick(C,p2_alive_not_self), picked2(P,C,T,_,Q), not app_alive(Q,T).
:- acts_pick(C,p2_alive_not_self), picked2(P,C,T,P,_).
:- acts_pick(C,p2_alive_not_self), picked2(P,C,T,_,P).
:- acts_pick(C,p2_not_self), picked2(P,C,T,P,_).
:- acts_pick(C,p2_not_self), picked2(P,C,T,_,P).
% at most one pick atom per acting instance (instance facts add, not join)
:- picked(P,C,T,Q1), picked(P,C,T,Q2), Q1 < Q2, acts_pick(C,PS),
   PS != p1_and_char.
:- picked2(P,C,T,Q1,Q2), picked2(P,C,T,Q3,Q4), Q1 != Q3.
:- picked2(P,C,T,Q1,Q2), picked2(P,C,T,Q3,Q4), Q2 != Q4.
1 { picked2(P,C,T,Q1,Q2) : player(Q1), player(Q2), Q1 < Q2 } 1 :-
    acting(P,C,T), acts_pick(C,p2_players).
1 { picked2(P,C,T,Q1,Q2) : player(Q1), player(Q2), Q1 < Q2,
                           Q1 != P, Q2 != P } 1 :-
    acting(P,C,T), acts_pick(C,p2_not_self).
% optional single pick ("you may choose a player")
0 { picked(P,C,T,Q) : player(Q) } 1 :-
    acting(P,C,T), acts_pick(C,p1_any_opt), not pick_suppressed(P,C,T).
1 { pickedc(P,C,T,CC) : in_pool(CC) } 1 :-
    acting(P,C,T), acts_pick(C,char_only).
1 { picked(P,C,T,Q) : alive(Q,T) } 1 :-
    acting(P,C,T), acts_pick(C,p1_and_char).
1 { pickedc(P,C,T,CC) : in_pool(CC) } 1 :-
    acting(P,C,T), acts_pick(C,p1_and_char).

% shadow picks (theater choices still happen; no world effects). Every pick
% spec is mirrored — a drunk-"Chambermaid" still chooses two alive players
% (caught by NQT #22: the charade branch was structurally unsatisfiable for
% specs without a shadow rule).
1 { picked(P,B,T,Q) : player(Q) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_any).
0 { picked(P,B,T,Q) : player(Q) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_any_opt).
1 { picked(P,B,T,Q) : app_alive(Q,T) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_alive).
1 { picked(P,B,T,Q) : app_alive(Q,T), Q != P } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_alive_not_self).
1 { picked(P,B,T,Q) : player(Q), Q != P } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_not_self).
1 { picked2(P,B,T,Q1,Q2) : player(Q1), player(Q2), Q1 < Q2 } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p2_players).
1 { picked2(P,B,T,Q1,Q2) : app_alive(Q1,T), app_alive(Q2,T), Q1 < Q2 } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p2_alive).
1 { picked2(P,B,T,Q1,Q2) : app_alive(Q1,T), app_alive(Q2,T), Q1 < Q2,
                           Q1 != P, Q2 != P } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p2_alive_not_self).
1 { picked2(P,B,T,Q1,Q2) : player(Q1), player(Q2), Q1 < Q2,
                           Q1 != P, Q2 != P } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p2_not_self).
1 { picked(P,B,T,Q) : app_alive(Q,T) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_and_char).
1 { pickedc(P,B,T,CC) : in_pool(CC) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,p1_and_char).
1 { pickedc(P,B,T,CC) : in_pool(CC) } 1 :-
    shadow_acting(P,B,T), acts_pick(B,char_only).

% ---------- statuses ----------
% applied(Target, Kind, src(P,C), T, I, Expiry)
% expiries: until_dusk(T) | tonight(T) | nights(K,T0) | permanent | until_death
% status_on(Q, Kind, T, I): active at night T just before order index I
% status_on_day(Q, Kind, D): active during day D

% night-scoped activation: applied earlier the same night
status_on(Q,K,T,I) :- applied(Q,K,Src,T,J,_), acts_idx(T,I), J < I,
                      not voided(Q,K,Src,T), not src_lost_mid(Q,K,Src,T,I).
% carry-over from previous nights, by expiry
status_on(Q,K,T,I) :- applied(Q,K,Src,T0,_,permanent), T0 < T, acts_idx(T,I),
                      not voided(Q,K,Src,T), not src_lost_mid(Q,K,Src,T,I).

% mid-night source loss: a status ends AT the position its source stops
% holding the granting ability — by transformation (star pass: the new Imp's
% poison victim is sober for later-in-the-night reads; NQT #59 confirmation)
% or by death.
src_lost_mid(Q,K,src(P,C),T,I) :- applied(Q,K,src(P,C),_,_,E),
    E != permanent_sticky, becomes(P,C2,T), C2 != C, becomes_at(P,T,I2),
    acts_idx(T,I), I >= I2.
src_lost_mid(Q,K,src(P,C),T,I) :- applied(Q,K,src(P,C),_,_,E),
    E != permanent_sticky, death_event(P,T), death_idx(P,T,I2),
    acts_idx(T,I), I >= I2, not persists_dead(P,C,T).
% permanent_sticky: outlives the source's ability (sweetheart, snake charmer)
status_on(Q,K,T,I) :- applied(Q,K,_,T0,_,permanent_sticky), T0 < T, acts_idx(T,I).
status_on(Q,K,T,I) :- applied(Q,K,_,T,J,permanent_sticky), acts_idx(T,I), J < I.
status_on_day(Q,K,D) :- applied(Q,K,_,T0,_,permanent_sticky), T0 <= D, day(D).
status_on(Q,K,T,I) :- applied(Q,K,Src,T0,_,nights(N,T0)), T0 < T, T <= T0+N-1,
                      acts_idx(T,I), not voided(Q,K,Src,T),
                      not src_lost_mid(Q,K,Src,T,I).
status_on_day(Q,K,D) :- applied(Q,K,Src,D,_,until_dusk(D)), day(D),
                        not voided(Q,K,Src,D), not voided_day(Q,K,Src,D).
status_on_day(Q,K,D) :- applied(Q,K,Src,T0,_,permanent), T0 <= D, day(D),
                        not voided(Q,K,Src,D), not voided_day(Q,K,Src,D).
% a status also ends when its source no longer holds the ability by dawn —
% e.g. the star-passed ex-Poisoner's poison ends (Poisoner almanac ex5)
voided_day(Q,K,src(P,C),D) :- applied(Q,K,src(P,C),_,_,E),
    E != permanent_sticky, day(D), not source_abled_day(P,C,D).
source_abled_day(P,C,D) :- char_d(P,C,D), alive(P,D), not dies_night(P,D),
                           day(D).
source_abled_day(P,C,D) :- char_d(P,C,D), persists_dead(P,C,D), day(D).
acts_idx(T,I) :- asched(_,T,I).
acts_idx(T,99) :- night(T).   % end-of-night evaluation point

% default: a status ends if its source loses the ability that granted it
% (permanent_sticky expiries are exempt and bypass this entirely)
voided(Q,K,src(P,C),T) :- applied(Q,K,src(P,C),_,_,E), E != permanent_sticky,
                          not has_ability(P,C,T), night(T).

% ---------- impairment & functioning ----------
drunk_kind(drunk). drunk_kind(poisoned).
impaired_at(P,T,I) :- status_on(P,K,T,I), drunk_kind(K).
impaired_at(P,T,I) :- initial(P,C), self_misinformed(C,_), acts_idx(T,I).
impaired_day(P,D) :- status_on_day(P,K,D), drunk_kind(K).
impaired_day(P,D) :- initial(P,C), self_misinformed(C,_), day(D).

functioning_at(P,C,T,I) :- has_ability(P,C,T), acts_idx(T,I),
                           not impaired_at(P,T,I), not sober_healthy(P,T).
functioning_at(P,C,T,I) :- has_ability(P,C,T), acts_idx(T,I), sober_healthy(P,T).
% sober_healthy: barista-style override (unused in base scripts; kept for shape)

% trace: woke / acted / malfunctioned
% woke/2 means woke DUE TO THEIR ABILITY (Chambermaid's printed wording):
% minion-info/demon-info wakes deliberately do NOT count (NQT #28
% solver-thread confirmation; the demon isn't "woken to choose" night 1).
woke(P,T) :- acting(P,C,T), asched(C,T,_).
woke(P,T) :- shadow_acting(P,B,T), sched(B,T,_).
acted(P,C,T) :- acting(P,C,T).
malfunctioned(P,T) :- acting(P,C,T), asched(C,T,I), impaired_at(P,T,I).
malfunctioned(P,T) :- shadow_acting(P,_,T).   % a charade never truly functions
