%%% death.lp — kill pipeline, protections, executions, revives, and the
%%% death-adjacent mechanics of the three base scripts.

% ---------- life state ----------
alive(P,1) :- player(P).
alive(P,T+1) :- alive(P,T), night(T+1), not dies_night(P,T), not dies_day(P,T).
alive(P,T+1) :- revived(P,T), night(T+1).
is_dead(P,T) :- player(P), night(T), not alive(P,T).

% apparent life (zombuul registers dead while mechanically alive)
app_alive(P,T) :- alive(P,T), not fake_dead(P,T).
app_dead(P,T) :- player(P), night(T), not app_alive(P,T).

% ---------- night kill proposals ----------
% eff_kill(C, PickSpec): acting C's pick dies (demon-kind unless eff_kill_kind)
kill_prop(Q, src(P,C), T, I, demon) :-
    eff_kill(C, p1), picked(P,C,T,Q), acting(P,C,T), sched(C,T,I),
    functioning_at(P,C,T,I), team_of(C,demon), not demon_blocked(P,T),
    not kill_suppressed(P,C,T).
kill_prop(Q1, src(P,C), T, I, demon) :-
    eff_kill(C, p2), picked2(P,C,T,Q1,_), acting(P,C,T), sched(C,T,I),
    functioning_at(P,C,T,I), not demon_blocked(P,T).
kill_prop(Q2, src(P,C), T, I, demon) :-
    eff_kill(C, p2), picked2(P,C,T,_,Q2), acting(P,C,T), sched(C,T,I),
    functioning_at(P,C,T,I), not demon_blocked(P,T).
% assassin: once per game, pierces everything
kill_prop(Q, src(P,assassin), T, I, pierce) :-
    picked(P,assassin,T,Q), uses_once(P,assassin,T), sched(assassin,T,I),
    functioning_at(P,assassin,T,I).

% ---------- mayor bounce ----------
% a protected mayor's ability does not trigger (Monk almanac): no bounce
bounceable(Q,Src,T,I) :- kill_prop(Q,Src,T,I,demon), char(Q,mayor,T),
                         functioning_at(Q,mayor,T,I), alive(Q,T),
                         not status_or_innate(Q,safe_from_demon,T,I),
                         not status_or_innate(Q,cant_die,T,I),
                         not status_or_innate(Q,safe_night,T,I).
1 { redirect(Q,Src,T,I,R) : alive(R,T) } 1 :- bounceable(Q,Src,T,I).
final_kill(R,Src,T,I,demon) :- redirect(_,Src,T,I,R).
final_kill(Q,Src,T,I,K) :- kill_prop(Q,Src,T,I,K), not bounceable(Q,Src,T,I).

% ---------- protections (night) ----------
% innate_status(C, Kind): holder has Kind while functioning
status_or_innate(Q,K,T,I) :- status_on(Q,K,T,I).
status_or_innate(Q,K,T,I) :- innate_status(C,K), char(Q,C,T),
                             functioning_at(Q,C,T,I).

prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,demon),
                        status_or_innate(Q,safe_from_demon,T,I).
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,demon),
                        status_or_innate(Q,cant_die,T,I).
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,st),
                        status_or_innate(Q,cant_die,T,I).
% tea lady aura: alive neighbours of a functioning tea lady can't die if both good
tealady_protects(Q,T,I) :- char(P,tealady,T), functioning_at(P,tealady,T,I),
    alive_neighbor(P,Q,T), align(Q,good,T),
    alive_neighbor(P,Q2,T), Q2 != Q, align(Q2,good,T).
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,demon), tealady_protects(Q,T,I).
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,st), tealady_protects(Q,T,I).
% fool: doesn't die the first time (while functioning)
0 { fool_saves(Q,T) } 1 :- final_kill(Q,Src,T,I,K), K != pierce,
    char(Q,fool,T), functioning_at(Q,fool,T,I), not fool_used(Q,T).
fool_used(Q,T2) :- fool_saves(Q,T), night(T2), T2 > T.
fool_used(Q,D2) :- fool_saves_exec(Q,D), day(D2), D2 > D.
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,_), fool_saves(Q,T).
% dead players can't die again
prevented(Q,Src,T,I) :- final_kill(Q,Src,T,I,_), not alive(Q,T).

% ---------- night deaths ----------
death_event(Q,T) :- final_kill(Q,_,T,I,pierce), alive(Q,T).
death_event(Q,T) :- final_kill(Q,Src,T,I,K), K != pierce,
                    not prevented(Q,Src,T,I).
% st-kill effects (gossip, godfather, moonchild, tinker) emit st_kill/2
death_event(Q,T) :- st_kill(Q,T), alive(Q,T), not st_kill_protected(Q,T).
st_kill_protected(Q,T) :- st_kill(Q,T), status_or_innate(Q,cant_die,T,99).
st_kill_protected(Q,T) :- st_kill(Q,T), tealady_protects(Q,T,99).

% zombuul: the first death isn't real
zombuul_first(Q,T) :- death_event(Q,T), char(Q,zombuul,T),
                      not zombuul_spent(Q,T).
zombuul_spent(Q,T2) :- zombuul_first(Q,T), night(T2), T2 > T.
zombuul_spent(Q,D2) :- zombuul_first_exec(Q,D), day(D2), D2 > D.
fake_dead(Q,T2) :- zombuul_first(Q,T), night(T2), T2 > T, alive(Q,T2).
fake_dead(Q,T2) :- zombuul_first_exec(Q,D), night(T2), T2 > D, alive(Q,T2).

dies_night(Q,T) :- death_event(Q,T), not zombuul_first(Q,T).

% dawn announcement: what town sees
announced_dead(Q,T) :- death_event(Q,T).

% ---------- executions & day deaths ----------
% observation supplies executed(P,D); death is the default outcome
exec_prevented(P,D) :- executed(P,D), char_d(P,C,D), innate_status(C,exec_safe),
                       functioning_day(P,C,D).
% devil's advocate protection
exec_prevented(P,D) :- executed(P,D), status_on_day(P,exec_safe,D).
% pacifist: ST may spare an executed good player
0 { pacifist_saves(P,D) } 1 :- executed(P,D), align(P,good,D),
    char_d(Q,pacifist,D), functioning_day(Q,pacifist,D).
exec_prevented(P,D) :- pacifist_saves(P,D).
% fool: first death, execution included
0 { fool_saves_exec(P,D) } 1 :- executed(P,D), char_d(P,fool,D),
    functioning_day(P,fool,D), not fool_used(P,D).
exec_prevented(P,D) :- fool_saves_exec(P,D).

exec_death(P,D) :- executed(P,D), alive(P,D), not exec_prevented(P,D).
zombuul_first_exec(P,D) :- exec_death(P,D), char_d(P,zombuul,D),
                           not zombuul_spent(P,D).
dies_day(P,D) :- exec_death(P,D), not zombuul_first_exec(P,D).
dies_day(P,D) :- day_kill(P,D), alive(P,D).   % slayer/witch/klutz via mech

executed_yesterday(P,T) :- exec_death(P,D), T = D+1, night(T).

functioning_day(P,C,D) :- char_d(P,C,D), alive(P,D), not dies_night(P,D),
                          not impaired_day(P,D).

% ---------- revives ----------
revived(P,T) :- revive_event(P,T).   % emitted by mech layer (professor, shabaloth)
