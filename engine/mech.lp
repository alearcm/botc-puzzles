%%% mech.lp — ability mechanics for the three base scripts, driven by card
%%% facts. Generic where possible (eff_status), specific where the almanac is.

% ---------- generic status effects ----------
% eff_status(C, Kind, Expiry): applied to picked1 target when C acts
applied(Q,K,src(P,C),T,I,until_dusk(T)) :-
    eff_status(C,K,until_dusk), picked(P,C,T,Q), acting(P,C,T), asched(C,T,I),
    functioning_at(P,C,T,I).
applied(Q,K,src(P,C),T,I,tonight(T)) :-
    eff_status(C,K,tonight), picked(P,C,T,Q), acting(P,C,T), asched(C,T,I),
    functioning_at(P,C,T,I).
applied(Q,K,src(P,C),T,I,permanent) :-
    eff_status(C,K,permanent), picked(P,C,T,Q), acting(P,C,T), asched(C,T,I),
    functioning_at(P,C,T,I).

% ---------- TB ----------
% imp star pass: self-kill passes to a minion
imp_suicide(P,T) :- death_event(P,T), char(P,imp,T), picked(P,imp,T,P).
1 { becomes(Q,imp,T) : alive(Q,T), char(Q,CM,T), team_of(CM,minion) } 1 :-
    imp_suicide(P,T).

% scarlet woman: becomes the demon if it dies with >=5 apparently-alive
demon_died(P,T,night) :- death_event(P,T), char(P,C,T), team_of(C,demon).
demon_died(P,D,exec) :- exec_death(P,D), char(P,C,D), team_of(C,demon).
sw_takes(Q,CD,T) :- demon_died(P,T,night), not imp_suicide(P,T),
    char(P,CD,T), char(Q,scarletwoman,T), functioning_at(Q,scarletwoman,T,99),
    alive(Q,T), Kc = #count{ R : app_alive(R,T) }, Kc >= 5.
sw_takes(Q,CD,D) :- demon_died(P,D,exec), char(P,CD,D),
    char(Q,scarletwoman,D), functioning_day(Q,scarletwoman,D), alive(Q,D),
    Kc = #count{ R : app_alive(R,D), not dies_day(R,D) }, Kc >= 5.
becomes(Q,CD,T) :- sw_takes(Q,CD,T).

% slayer: public day shot (input slayer_shot(P,Q,D))
site_dm(sly(P,D,Q),Q,D) :- slayer_shot(P,Q,D).
day_kill(Q,D) :- slayer_shot(P,Q,D), char(P,slayer,D),
    functioning_day(P,slayer,D), not slayer_spent(P,D),
    reg_demon(Q,sly(P,D,Q)).
slayer_spent(P,D2) :- slayer_shot(P,_,D), day(D2), D2 > D.

% virgin: nomination proc (inputs nominated/3, proc_virgin/2 observed)
site_tm(vrg(V,D,N),N,D) :- nominated(N,V,D), char(V,virgin,D).
virgin_would(N,V,D) :- nominated(N,V,D), char(V,virgin,D),
    functioning_day(V,virgin,D), not virgin_spent(V,D),
    reg_team(N,townsfolk,vrg(V,D,N)).
virgin_spent(V,D2) :- nominated(_,V,D), char(V,virgin,D), day(D2), D2 > D.
:- proc_virgin(N,D), nominated(N,V,D), not virgin_would(N,V,D).
:- no_proc_virgin(N,D), nominated(N,V,D), virgin_would(N,V,D).

% ravenkeeper: on night-death trigger (acts when dead at night)
rk_triggered(P,T) :- death_event(P,T), char(P,ravenkeeper,T).
acting(P,ravenkeeper,T) :- rk_triggered(P,T), has_ability_dead_trigger(P,ravenkeeper,T).
has_ability_dead_trigger(P,C,T) :- char(P,C,T), alive(P,T).  % died this night
1 { picked(P,ravenkeeper,T,Q) : player(Q) } 1 :- rk_triggered(P,T).
token_due(P,ravenkeeper,T,char_of_picked) :- rk_triggered(P,T).
% shadow ravenkeeper (drunk-as-ravenkeeper): S1 charade on death
shadow_rk(P,T) :- death_event(P,T), believed_init(P,ravenkeeper),
                  initial(P,C), self_misinformed(C,_).
1 { picked(P,ravenkeeper,T,Q) : player(Q) } 1 :- shadow_rk(P,T).
token_due(P,ravenkeeper,T,char_of_picked) :- shadow_rk(P,T).
shadow_token(P,ravenkeeper,T) :- shadow_rk(P,T).
woke(P,T) :- shadow_rk(P,T).
woke(P,T) :- rk_triggered(P,T).

% ---------- BMR ----------
% sailor: either you or the target is drunk until dusk (ST choice)
1 { sailor_hit(P,T,P) ; sailor_hit(P,T,Q) } 1 :-
    picked(P,sailor,T,Q), acting(P,sailor,T), sched(sailor,T,I),
    functioning_at(P,sailor,T,I).
applied(R,drunk,src(P,sailor),T,I,until_dusk(T)) :-
    sailor_hit(P,T,R), sched(sailor,T,I).
innate_status(sailor,cant_die).      % while sober (functioning gate applies)

% innkeeper: both safe, one drunk (ST choice)
applied(Q1,safe_night,src(P,innkeeper),T,I,tonight(T)) :-
    picked2(P,innkeeper,T,Q1,_), acting(P,innkeeper,T), sched(innkeeper,T,I),
    functioning_at(P,innkeeper,T,I).
applied(Q2,safe_night,src(P,innkeeper),T,I,tonight(T)) :-
    picked2(P,innkeeper,T,_,Q2), acting(P,innkeeper,T), sched(innkeeper,T,I),
    functioning_at(P,innkeeper,T,I).
1 { inn_drunk(P,T,Q1) ; inn_drunk(P,T,Q2) } 1 :-
    picked2(P,innkeeper,T,Q1,Q2), acting(P,innkeeper,T), sched(innkeeper,T,I),
    functioning_at(P,innkeeper,T,I).
applied(Q,drunk,src(P,innkeeper),T,I,until_dusk(T)) :-
    inn_drunk(P,T,Q), sched(innkeeper,T,I).
prevented(Q,Src,T,I2) :- final_kill(Q,Src,T,I2,_), status_on(Q,safe_night,T,I2).
st_kill_protected(Q,T) :- st_kill(Q,T), status_on(Q,safe_night,T,99).

% courtier: once, pick a character: its holder is drunk for 3 days
1 { pickedc(P,courtier,T,CC) : on_script(CC) } 1 :- uses_once(P,courtier,T).
applied(Q,drunk,src(P,courtier),T,I,nights(3,T)) :-
    pickedc(P,courtier,T,CC), char(Q,CC,T), sched(courtier,T,I),
    functioning_at(P,courtier,T,I).

% exorcist: chosen demon doesn't act
demon_blocked(Q,T) :- picked(P,exorcist,T,Q), acting(P,exorcist,T),
    sched(exorcist,T,I), functioning_at(P,exorcist,T,I),
    char(Q,C,T), team_of(C,demon).

% gambler: guesses own pick's character; wrong -> dies
site_ch(gmb(P,T,Q),Q,T) :- picked(P,gambler,T,Q), acting(P,gambler,T).
gambler_wrong(P,T) :- picked(P,gambler,T,Q), pickedc(P,gambler,T,CC),
    sched(gambler,T,I), functioning_at(P,gambler,T,I),
    not reg_char(Q,CC,gmb(P,T,Q)).
st_kill(P,T) :- gambler_wrong(P,T).

% gossip: true public statement -> a player dies that night (ST choice)
gossip_fires(P,D) :- gossip_stmt(Id,P,D), stmt_true(Id), char(P,gossip,D),
                     functioning_day(P,gossip,D).
1 { st_kill(Q,T) : alive(Q,T) } 1 :- gossip_fires(P,D), T = D+1, night(T).

% godfather: outsider executed/died today -> kills tonight
outsider_died(D) :- dies_day(Q,D), char(Q,C,D), team_of(C,outsider).
1 { picked(P,godfather,T,Q) : alive(Q,T) } 1 :-
    char(P,godfather,T), has_ability(P,godfather,T), outsider_died(D), T = D+1,
    night(T).
st_kill(Q,T) :- picked(P,godfather,T,Q), outsider_died(D), T = D+1,
    sched(godfather,T,I), functioning_at(P,godfather,T,I).

% devil's advocate: chosen player survives execution tomorrow
applied(Q,exec_safe,src(P,devilsadvocate),T,I,until_dusk(T)) :-
    picked(P,devilsadvocate,T,Q), acting(P,devilsadvocate,T),
    sched(devilsadvocate,T,I), functioning_at(P,devilsadvocate,T,I).

% moonchild: on death chooses (input moonchild_choice/3); good choice dies tonight
st_kill(Q,T) :- moonchild_choice(P,Q,D), T = D+1, night(T), char(P,moonchild,D),
    align(Q,good,T).

% tinker: may die at any time (night or day)
0 { tinker_dies(P,T) } 1 :- char(P,tinker,T), alive(P,T), night(T).
st_kill(P,T) :- tinker_dies(P,T).
0 { tinker_dies_day(P,D) } 1 :- char(P,tinker,D), alive(P,D), day(D),
                                not dies_night(P,D).
day_kill(P,D) :- tinker_dies_day(P,D).

% butler: may only vote if the chosen master votes (votes are day inputs)
:- voted(P,D), char(P,butler,D), not impaired_day(P,D),
   picked(P,butler,D,M), not voted(M,D).

% philosopher: once per game, gain a good character's ability; if that
% character is in play, its holder is drunk (while the philosopher has it)
1 { phil_pick(P,T,CC) : role(CC,TM,_), good_team(TM), on_script(CC),
                        CC != philosopher } 1 :- uses_once(P,philosopher,T).
phil_gains(P,CC,T) :- phil_pick(P,T,CC), asched(philosopher,T,I),
                      functioning_at(P,philosopher,T,I).
has_ability(P,CC,T2) :- phil_gains(P,CC,T), night(T2), T2 >= T, alive(P,T2).
ability_start(P,CC,T) :- phil_gains(P,CC,T).
applied(Q,drunk,src(P,philosopher),T,I,permanent) :-
    phil_gains(P,CC,T), char(Q,CC,T), Q != P, asched(philosopher,T,I).

% professor: once, revive a dead townsfolk
1 { picked(P,professor,T,Q) : is_dead(Q,T) } 1 :- uses_once(P,professor,T).
revive_event(Q,T) :- picked(P,professor,T,Q), uses_once(P,professor,T),
    sched(professor,T,I), functioning_at(P,professor,T,I),
    char(Q,CC,T), team_of(CC,townsfolk).

% minstrel: minion executed -> everyone drunk until dusk tomorrow
minstrel_on(D) :- exec_death(Q,D), char(Q,C,D), team_of(C,minion),
    char(P,minstrel,D), functioning_day(P,minstrel,D).
applied(Q,drunk,src(P,minstrel),T,0,until_dusk(T)) :-
    minstrel_on(D), T = D+1, night(T), player(Q), char(P,minstrel,D).

% goon: first targeter becomes drunk; goon turns their alignment
targeted(Q,P,C,T,I) :- picked(P,C,T,Q), acting(P,C,T), sched(C,T,I).
targeted(Q,P,C,T,I) :- picked2(P,C,T,Q,_), acting(P,C,T), sched(C,T,I).
targeted(Q,P,C,T,I) :- picked2(P,C,T,_,Q), acting(P,C,T), sched(C,T,I).
goon_first(G,P,C,T,I) :- char(G,goon,T), has_ability(G,goon,T),
    targeted(G,P,C,T,I), not impaired_at(G,T,I),
    #false : targeted(G,_,_,T,I2), I2 < I.
applied(P,drunk,src(G,goon),T,I,until_dusk(T)) :- goon_first(G,P,C,T,I).
align_change(G,A,T) :- goon_first(G,P,C,T,I), align(P,A,T).

% zombuul: only acts if nobody died today
demon_blocked(P,T) :- char(P,zombuul,T), T = D+1, day(D), died_today(D).
died_today(D) :- dies_day(_,D).
died_today(D) :- zombuul_first_exec(_,D).        % town SAW a death
died_today(D) :- announced_dead(_,D2), D2 = D.   % night deaths announce at dawn D

% pukka: poison now, victim dies next night then healthy
applied(Q,poisoned,src(P,pukka),T,I,nights(2,T)) :-
    picked(P,pukka,T,Q), acting(P,pukka,T), sched(pukka,T,I),
    functioning_at(P,pukka,T,I).
kill_prop(Q,src(P,pukka),T2,I,demon) :- picked(P,pukka,T,Q), T2 = T+1,
    night(T2), sched(pukka,T2,I), char(P,pukka,T2), has_ability(P,pukka,T2),
    functioning_at(P,pukka,T2,I).

% shabaloth: may regurgitate a victim from the previous night
shab_victim(Q,T0) :- picked2(_,shabaloth,T0,Q,_).
shab_victim(Q,T0) :- picked2(_,shabaloth,T0,_,Q).
0 { revive_event(Q,T) : shab_victim(Q,T-1) } 1 :-
    char(P,shabaloth,T), acting(P,shabaloth,T), night(T), T > 1.

% po: charge or kill (p1 pick = kill; charge modelled as self-pick)
po_charged(P,T) :- picked(P,po,T,P), not po_ready(P,T).
% on a burst night the regular pick is inert (self-pick by convention)
kill_suppressed(P,po,T) :- po_ready(P,T).
% after charging: exactly 3 targets (or all remaining if fewer than 3 alive)
po_ready(P,T) :- po_charged(P,T0), T = T0+1, night(T), acting(P,po,T).
po_pool(P,T,K) :- po_ready(P,T), K = #count{ Q : app_alive(Q,T) }.
3 { po_extra(P,T,Q) : app_alive(Q,T) } 3 :- po_ready(P,T), po_pool(P,T,K), K >= 3.
K { po_extra(P,T,Q) : app_alive(Q,T) } K :- po_ready(P,T), po_pool(P,T,K), K < 3.
kill_prop(Q,src(P,po),T,I,demon) :- po_extra(P,T,Q), sched(po,T,I),
    functioning_at(P,po,T,I).
% (normal po kill comes from eff_kill(po,p1); self-pick must not kill)
prevented(P,src(P,po),T,I) :- final_kill(P,src(P,po),T,I,demon), po_charged(P,T).

% ---------- S&V ----------
% snake charmer: hits the actual demon -> swap, effective SAME night: the new
% demon (ex-charmer) acts at the demon's position tonight; the old demon
% (now snake charmer) does not act again.
sc_hit(P,Q,T) :- picked(P,snakecharmer,T,Q), acting(P,snakecharmer,T),
    sched(snakecharmer,T,I), functioning_at(P,snakecharmer,T,I),
    char(Q,C,T), team_of(C,demon).
becomes(P,CD,T) :- sc_hit(P,Q,T), char(Q,CD,T).
becomes(Q,snakecharmer,T) :- sc_hit(P,Q,T).
align_change(P,evil,T) :- sc_hit(P,Q,T).
align_change(Q,good,T) :- sc_hit(P,Q,T).
% new snake charmer is poisoned forever (outlives everything)
applied(Q,poisoned,src(P,snakecharmer),T,I,permanent_sticky) :-
    sc_hit(P,Q,T), sched(snakecharmer,T,I).
% same-night demon handover
demon_blocked(Q,T) :- sc_hit(_,Q,T).
has_ability(P,CD,T) :- sc_hit(P,Q,T), char(Q,CD,T).
acting(P,CD,T) :- sc_hit(P,Q,T), char(Q,CD,T), acts(CD,other,_), T > 1.

% witch: cursed player dies if they nominate
applied(Q,cursed,src(P,witch),T,I,until_dusk(T)) :-
    picked(P,witch,T,Q), acting(P,witch,T), sched(witch,T,I),
    functioning_at(P,witch,T,I).
day_kill(N,D) :- nominated(N,_,D), status_on_day(N,cursed,D),
    Kc = #count{ R : app_alive(R,D) }, Kc >= 4.

% cerenovus: madness flag only (no enforcement semantics in v1)
mad(Q,CC,D) :- picked(P,cerenovus,T,Q), pickedc(P,cerenovus,T,CC),
    acting(P,cerenovus,T), sched(cerenovus,T,I),
    functioning_at(P,cerenovus,T,I), D = T, day(D).

% pit-hag: transform; demon creation -> arbitrary deaths licence
ph_change(P,Q,CC,T) :- picked(P,pithag,T,Q), pickedc(P,pithag,T,CC),
    acting(P,pithag,T), sched(pithag,T,I), functioning_at(P,pithag,T,I),
    not in_play_now(CC,T).
in_play_now(CC,T) :- char(_,CC,T).
becomes(Q,CC,T) :- ph_change(_,Q,CC,T).
ph_demon_made(T) :- ph_change(_,Q,CC,T), team_of(CC,demon).
{ st_kill(Q,T) : alive(Q,T) } :- ph_demon_made(T).

% fang gu: outsider target jumps (once per game)
fg_jump(P,Q,T) :- picked(P,fanggu,T,Q), acting(P,fanggu,T), sched(fanggu,T,I),
    functioning_at(P,fanggu,T,I), char(Q,C,T), team_of(C,outsider),
    not fg_jumped_before(T).
fg_jumped_before(T2) :- fg_jump(_,_,T), night(T2), T2 > T.
becomes(Q,fanggu,T) :- fg_jump(P,Q,T).
align_change(Q,evil,T) :- fg_jump(P,Q,T).
st_kill(P,T) :- fg_jump(P,Q,T).
prevented(Q,src(P,fanggu),T,I) :- final_kill(Q,src(P,fanggu),T,I,demon),
    fg_jump(P,Q,T).

% vigormortis: killed minion keeps ability; poisons an adjacent townsfolk
vm_kill(P,Q,T) :- death_event(Q,T), final_kill(Q,src(P,vigormortis),T,_,demon),
    char(Q,CM,T), team_of(CM,minion).
persists_dead(Q,CM,T2) :- vm_kill(P,Q,T), char(Q,CM,T), night(T2), T2 > T,
    char(P,vigormortis,T2), has_ability(P,vigormortis,T2).
1 { vm_poison(P,Q,R,T) : alive_neighbor(Q,R,T), char(R,CT,T),
                         team_of(CT,townsfolk) } 1 :-
    vm_kill(P,Q,T), alive_neighbor(Q,R2,T), char(R2,CT2,T),
    team_of(CT2,townsfolk).
applied(R,poisoned,src(P,vigormortis),T,I,permanent) :-
    vm_poison(P,Q,R,T), sched(vigormortis,T,I).

% no dashii: adjacent townsfolk poisoned (nearest alive townsfolk each way)
nd_poisons(P,R,T) :- char(P,nodashii,T), has_ability(P,nodashii,T),
    alive_neighbor_tf(P,R,T).
alive_neighbor_tf(P,R,T) :- char(P,nodashii,T), alive(R,T), night(T),
    char(R,CT,T), team_of(CT,townsfolk), nd_nearest(P,R,T).
% nearest alive townsfolk clockwise / counter-clockwise
nd_nearest(P,R,T) :- walk(P,R,N), alive(R,T), char(R,CT,T),
    team_of(CT,townsfolk),
    #false : walk(P,R2,N2), N2 < N, alive(R2,T), char(R2,CT2,T),
             team_of(CT2,townsfolk).
nd_nearest(P,R,T) :- walkc(P,R,N), alive(R,T), char(R,CT,T),
    team_of(CT,townsfolk),
    #false : walkc(P,R2,N2), N2 < N, alive(R2,T), char(R2,CT2,T),
             team_of(CT2,townsfolk).
status_on(R,poisoned,T,I) :- nd_poisons(P,R,T), acts_idx(T,I).
status_on_day(R,poisoned,D) :- nd_poisons(P,R,D), day(D), not dies_night(R,D).

% sweetheart: on death, ST picks someone drunk permanently
1 { sw_drunk(P,Q,T) : player(Q) } 1 :- death_event(P,T), char(P,sweetheart,T).
1 { sw_drunk(P,Q,D) : player(Q) } 1 :- dies_day(P,D), char(P,sweetheart,D).
% the drunking starts AT the moment of death, not retroactively: abilities
% earlier in the same night already resolved sober
death_idx(Q,T,I) :- final_kill(Q,_,T,I,_), death_event(Q,T).
death_idx(Q,T,99) :- st_kill(Q,T), death_event(Q,T).
applied(Q,drunk,src(P,sweetheart),T,I,permanent_sticky) :-
    sw_drunk(P,Q,T), death_idx(P,T,I), night(T).
applied(Q,drunk,src(P,sweetheart),D,0,permanent_sticky) :-
    sw_drunk(P,Q,D), dies_day(P,D).

% barber: on death, demon may swap two players' characters
0 { barber_swap(Q1,Q2,T) : player(Q1), player(Q2), Q1 < Q2 } 1 :-
    death_event(P,T), char(P,barber,T).
% day-death: the swap happens the following night (chars change at its end)
0 { barber_swap(Q1,Q2,D) : player(Q1), player(Q2), Q1 < Q2 } 1 :-
    dies_day(P,D), char(P,barber,D), night(D+1).
becomes(Q1,C2,T) :- barber_swap(Q1,Q2,T), char(Q2,C2,T).
becomes(Q2,C1,T) :- barber_swap(Q1,Q2,T), char(Q1,C1,T).

% sage: on demon-death at night, learns 2 (demon among them)
sage_killer(P,T,QD) :- death_event(P,T), char(P,sage,T),
    final_kill(P,src(QD,CD),T,_,demon).
token_due(P,sage,T,sage_pair) :- sage_killer(P,T,_).
woke(P,T) :- sage_killer(P,T,_).

% evil twin: pair exists (world structure; win-condition deferred)
1 { twin_pair(P,Q) : player(Q), Q != P } 1 :- initial(P,eviltwin).
:- twin_pair(P,Q), align(P,A,1), align(Q,A,1).

% artist: once per game day question (inputs artist_q/3 + stmt_true)
1 { shown_bool(P,artist,D,yes) ; shown_bool(P,artist,D,no) } 1 :-
    artist_q(Id,P,D).
artist_yes(P,D) :- artist_q(Id,P,D), stmt_true(Id).
:- shown_bool(P,artist,D,yes), artist_q(Id,P,D), not impaired_day(P,D),
   not vortox_alive(D), not artist_yes(P,D).
:- shown_bool(P,artist,D,no), artist_q(Id,P,D), not impaired_day(P,D),
   not vortox_alive(D), artist_yes(P,D).
:- shown_bool(P,artist,D,yes), artist_q(Id,P,D), vortox_alive(D), artist_yes(P,D).
:- shown_bool(P,artist,D,no), artist_q(Id,P,D), vortox_alive(D), not artist_yes(P,D).
vortox_alive(T) :- char(V,vortox,T), has_ability(V,vortox,T).
