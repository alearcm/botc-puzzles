%%% endgame.lp — win/endgame semantics as world constraints.
%%% Phases are linearised: night T = 2T-1, day D = 2D. `assume_ongoing.`
%%% (added automatically for puzzles) forbids any game end strictly before
%%% the final phase — "we are still playing" is itself evidence.

% ---------- demon presence after a phase ----------
demon_after_night(T) :- char(P,C,T), team_of(C,demon), alive(P,T),
    not dies_night(P,T), not char_changed(P,T), night(T).
demon_after_night(T) :- becomes(P,C,T), team_of(C,demon), alive(P,T),
    not dies_night(P,T), night(T).
% zombuul fake-dead is mechanically alive: covered by alive/4 above
demon_after_day(D) :- char_d(P,C,D), team_of(C,demon), alive(P,D),
    not dies_night(P,D), not dies_day(P,D), day(D), not day_changed(P,D).
demon_after_day(D) :- becomes_day(P,C,D), team_of(C,demon), alive(P,D),
    not dies_night(P,D), not dies_day(P,D), day(D).
day_changed(P,D) :- becomes_day(P,_,D).

% ---------- good wins: demon eliminated ----------
ended(2*T-1,good) :- night(T), not demon_after_night(T), not twin_block_n(T).
ended(2*D,good)   :- day(D), not demon_after_day(D), not mm_active(D),
                     not twin_block_d(D).

% evil twin: good cannot win while both twins live (functioning evil twin)
twin_block_n(T) :- twin_pair(P,Q), alive(P,T), alive(Q,T), night(T),
                   has_ability(P,eviltwin,T), not impaired_at(P,T,99).
twin_block_d(D) :- twin_pair(P,Q), alive(P,D), alive(Q,D), day(D),
    not dies_day(P,D), not dies_day(Q,D), has_ability(P,eviltwin,D),
    not impaired_day(P,D).

% evil twin: executing the good twin ends the game for evil
ended(2*D,evil) :- exec_death(Q,D), twin_pair(P,Q),
                   has_ability(P,eviltwin,D), not impaired_day(P,D).

% ---------- evil wins: 2 or fewer alive with a demon ----------
alive_after_day(P,D) :- alive(P,D), day(D), not dies_night(P,D),
                        not dies_day(P,D).
ended(2*D,evil) :- day(D), demon_after_day(D),
                   #count{ P : alive_after_day(P,D) } <= 2.

% ---------- saint: executed while functioning -> evil wins ----------
ended(2*D,evil) :- exec_death(P,D), char_d(P,saint,D), not impaired_day(P,D).

% ---------- klutz: on-death public choice (input klutz_choice/3) ----------
site_al(klz(P,D,Q),Q,D) :- klutz_choice(P,Q,D).
ended(2*D,evil) :- klutz_choice(P,Q,D), char_d(P,klutz,D),
                   not impaired_day(P,D), reg_evil(Q,klz(P,D,Q)).

% ---------- mayor: 3 alive, no execution -> good wins ----------
ended(2*D,good) :- day(D), char_d(P,mayor,D), functioning_day(P,mayor,D),
    not dies_day(P,D), #count{ Q : alive_after_day(Q,D) } = 3,
    not any_exec(D), not twin_block_d(D).
any_exec(D) :- executed(_,D).

% ---------- vortox: no execution in a day -> evil wins ----------
ended(2*D,evil) :- day(D), vortox_alive(D), not any_exec(D).

% ---------- leviathan: execution-count clock (no night kill) ----------
% "If more than 1 good player is executed, you win. After day 5, evil wins."
lev_alive(D) :- day(D), char_d(P,leviathan,D), alive(P,D), not dies_night(P,D).
ended(2*D,evil) :- lev_alive(D),
    #count{ P,D2 : exec_death(P,D2), day(D2), D2 <= D, align(P,good,D2) } >= 2.
ended(2*D,evil) :- lev_alive(D), D >= 5.

% ---------- mastermind: demon executed -> one more day ----------
mm_active(D) :- exec_death(P,D), char_d(P,C,D), team_of(C,demon),
    char_d(M,mastermind,D), alive(M,D), not dies_day(M,D),
    not impaired_day(M,D), not demon_after_day(D).
mm_window(D2) :- mm_active(D), D2 = D+1, day(D2).
ended(2*D2,evil) :- mm_window(D2), exec_death(Q,D2), align(Q,good,D2).
ended(2*D2,good) :- mm_window(D2), exec_death(Q,D2), align(Q,evil,D2).
ended(2*D2,good) :- mm_window(D2), not any_exec(D2).

% ---------- ongoing-play constraint ----------
% a puzzle posed about a live game means the game has not ended at ALL —
% including the final phase (a demon suicide on the last night still ends it)
:- assume_ongoing, ended(_,_).
horizon(horizon).
