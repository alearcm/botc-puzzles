%%% info.lp — registration, tokens, the claim library, truth-pattern modes.

% ================= registration =================
% Sites are opaque terms created by claim rules. reg atoms exist per site.
% Misregistration is part of the misregistering character's ability: it
% requires that character to be functioning at evaluation time.

% --- the site clock ---
% A site is one evaluation occurrence; site_pos(Site,I) is the night-order
% position it evaluates at (the observer's own slot). State reads see every
% change that resolved at an earlier position — the grimoire updates as the
% night proceeds. No per-interaction rules: a Fortune Teller checking after
% a star pass sees the new Imp BECAUSE the Imp acts earlier, not because we
% coded that pairing. Sites without a position (day sites, reads about
% yesterday's events) use the phase-boundary state.
scq(S,Q,T) :- site_al(S,Q,T).   scq(S,Q,T) :- site_ch(S,Q,T).
scq(S,Q,T) :- site_dm(S,Q,T).   scq(S,Q,T) :- site_tm(S,Q,T).
% effective position: earliest if a site somehow accrues several (e.g. a
% philosopher-gained ability whose card also has a sheet slot)
site_epos(S,I) :- site_pos(S,I), not site_pos_lt(S,I).
site_pos_lt(S,I) :- site_pos(S,I), site_pos(S,J), J < I.
has_pos(S) :- site_pos(S,_).

eval_at(Q,T,I) :- scq(S,Q,T), site_epos(S,I).
% actions that read positional state (snake charmer's demon check, ...)
% register their evaluation points the same way
eval_at(Q,T,I) :- act_eval(Q,T,I).
chg_seen(Q,T,I) :- eval_at(Q,T,I), becomes_at(Q,T,J), J < I.
eff_char_n(Q,C,T,I) :- eval_at(Q,T,I), char(Q,C,T), not chg_seen(Q,T,I).
eff_char_n(Q,C,T,I) :- chg_seen(Q,T,I), becomes(Q,C,T).
al_chg_seen(Q,T,I) :- eval_at(Q,T,I), align_change_at(Q,T,J), J < I.
eff_align_n(Q,A,T,I) :- eval_at(Q,T,I), align(Q,A,T), not al_chg_seen(Q,T,I).
eff_align_n(Q,A,T,I) :- al_chg_seen(Q,T,I), align_change(Q,A,T).

% state as seen by each site
site_char(Q,C,S) :- scq(S,Q,T), site_epos(S,I), eff_char_n(Q,C,T,I).
site_char(Q,C,S) :- scq(S,Q,T), not has_pos(S), not site_day(S), char(Q,C,T).
site_char(Q,C,S) :- scq(S,Q,D), site_day(S), char_d(Q,C,D).
site_align(Q,A,S) :- site_al(S,Q,T), site_epos(S,I), eff_align_n(Q,A,T,I).
site_align(Q,A,S) :- site_al(S,Q,T), not has_pos(S), align(Q,A,T).

% --- alignment registration ---
% subjects that MAY register evil (recluse) / good (spy)
% NOTE: deliberately no aliveness requirement — the executed Recluse may
% register as the Imp to the Undertaker (Recluse almanac, T0). Whether
% droison strips misregistration is itself a seam; current default: it does
% (checked at the site's own position when it has one).
may_misreg_evil(Q,S) :- site_char(Q,recluse,S), scq(S,Q,T),
                        site_epos(S,I), not impaired_at(Q,T,I).
may_misreg_evil(Q,S) :- site_char(Q,recluse,S), scq(S,Q,T),
                        not has_pos(S), not impaired_at(Q,T,99).
may_misreg_good(Q,S) :- site_char(Q,spy,S), scq(S,Q,T),
                        site_epos(S,I), not impaired_at(Q,T,I).
may_misreg_good(Q,S) :- site_char(Q,spy,S), scq(S,Q,T),
                        not has_pos(S), not impaired_at(Q,T,99).

0 { mr_evil(Q,Site) } 1 :- site_al(Site,Q,T), site_align(Q,good,Site),
                           may_misreg_evil(Q,Site).
0 { mr_good(Q,Site) } 1 :- site_al(Site,Q,T), site_align(Q,evil,Site),
                           may_misreg_good(Q,Site).

reg_evil(Q,Site) :- site_align(Q,evil,Site), not mr_good(Q,Site).
reg_evil(Q,Site) :- mr_evil(Q,Site).
reg_good(Q,Site) :- site_al(Site,Q,T), not reg_evil(Q,Site).

% --- character registration ---
% default: character as seen at the site's position; recluse may register
% as any pool minion/demon; spy as any pool townsfolk/outsider.
0 { mr_char(Q,Site,CC) : role(CC,TM,_), in_pool(CC), evil_team(TM) } 1 :-
    site_ch(Site,Q,T), may_misreg_evil(Q,Site).
0 { mr_char(Q,Site,CC) : role(CC,TM,_), in_pool(CC), good_team(TM) } 1 :-
    site_ch(Site,Q,T), may_misreg_good(Q,Site).
reg_char(Q,CC,Site) :- mr_char(Q,Site,CC).
reg_char(Q,CC,Site) :- site_ch(Site,Q,T), site_char(Q,CC,Site),
                       not mr_char(Q,Site,_).

% --- demon registration (fortune teller / slayer style checks) ---
reg_demon(Q,Site) :- site_dm(Site,Q,T), site_char(Q,C,Site), team_of(C,demon).
% red herring: one good player registers as demon to the fortune teller
1 { red_herring(Q) : player(Q) } 1 :- in_play(fortuneteller).
:- red_herring(Q), initial(Q,C), team_of(C,TM), evil_team(TM).
reg_demon(Q,Site) :- site_dm(Site,Q,T), red_herring(Q), ft_site(Site).
0 { mr_demon(Q,Site) } 1 :- site_dm(Site,Q,T), may_misreg_evil(Q,Site).
reg_demon(Q,Site) :- mr_demon(Q,Site).

% --- team registration (virgin's townsfolk check, towncrier's minion check) ---
reg_team(Q,TM,Site) :- site_tm(Site,Q,T), site_char(Q,C,Site), team_of(C,TM),
                       not mr_team(Q,Site,_).
0 { mr_team(Q,Site,TM) : good_team(TM) } 1 :- site_tm(Site,Q,T),
                                              may_misreg_good(Q,Site).
0 { mr_team(Q,Site,TM) : evil_team(TM) } 1 :- site_tm(Site,Q,T),
                                              may_misreg_evil(Q,Site).
reg_team(Q,TM,Site) :- mr_team(Q,Site,TM).

% --- site positions ---
% Each night site evaluates at its observer's own slot. Deliberately
% positionless: flg/tcr (they ask about YESTERDAY's votes/nominations, so
% the subject's day-time state is what matters, approximated by the
% phase-boundary read — see DEBT), jug (day site), sly (day site).
site_pos(am2(P,C,T,Q),I)  :- site_ch(am2(P,C,T,Q),Q,T),  asched(C,T,I).
site_pos(am2n(P,C,T,Q),I) :- site_ch(am2n(P,C,T,Q),Q,T), asched(C,T,I).
site_pos(chefp(P,T,Q1,Q2,Q),I) :- site_al(chefp(P,T,Q1,Q2,Q),Q,T),
                                  asched(chef,T,I).
site_pos(emp(P,T,Q),I) :- site_al(emp(P,T,Q),Q,T), asched(empath,T,I).
site_pos(ftq(P,T,Q),I) :- site_dm(ftq(P,T,Q),Q,T), asched(fortuneteller,T,I).
site_pos(und(P,T,Q),I) :- site_ch(und(P,T,Q),Q,T), asched(undertaker,T,I).
site_pos(rvk(P,T,Q),I) :- site_ch(rvk(P,T,Q),Q,T), asched(ravenkeeper,T,I).
site_pos(gm(P,T,Q),I)  :- site_ch(gm(P,T,Q),Q,T),  asched(grandmother,T,I).
site_pos(drm(P,T,Q),I) :- site_ch(drm(P,T,Q),Q,T), asched(dreamer,T,I).
site_pos(orc(P,T,Q),I) :- site_al(orc(P,T,Q),Q,T), asched(oracle,T,I).
site_pos(sea(P,T,Q),I) :- site_al(sea(P,T,Q),Q,T), asched(seamstress,T,I).
site_pos(gf(P,T,Q),I)  :- site_ch(gf(P,T,Q),Q,T),  asched(godfather,T,I).

% ================= tokens & modes =================
% learns(C, first|other|each, Schema) from cards.
token_due(P,C,T,Schema) :- learns(C,first,Schema), acting(P,C,T), T = 1.
% first-night info abilities gained mid-game (philosopher/pit-hag creations)
token_due(P,C,T,Schema) :- learns(C,first,Schema), acting(P,C,T),
                           ability_start(P,C,T), T > 1.
token_due(P,C,T,Schema) :- learns(C,other,Schema), acting(P,C,T), T > 1.
token_due(P,C,T,Schema) :- learns(C,each,Schema),  acting(P,C,T).
% shadow tokens: theater info, always FREE
token_due(P,B,T,Schema) :- learns(B,first,Schema), shadow_acting(P,B,T), T = 1.
token_due(P,B,T,Schema) :- learns(B,other,Schema), shadow_acting(P,B,T), T > 1.
token_due(P,B,T,Schema) :- learns(B,each,Schema),  shadow_acting(P,B,T).

shadow_token(P,B,T) :- token_due(P,B,T,_), shadow_acting(P,B,T).

% mode precedence: sober_healthy > vortox > droison/shadow > base
m_vortox(P,C,T) :- token_due(P,C,T,_), role(C,townsfolk,_),
    char(V,vortox,T), has_ability(V,vortox,T).
m_free(P,C,T) :- token_due(P,C,T,_), asched(C,T,I), impaired_at(P,T,I).
m_free(P,C,T) :- shadow_token(P,C,T).
m_free(P,savant,T) :- token_due(P,savant,T,savant_visit), impaired_day(P,T).

info_mode(P,C,T,all_false) :- m_vortox(P,C,T), not sober_healthy(P,T),
                              not shadow_token(P,C,T).   % delta: drunk-under-vortox
info_mode(P,C,T,free) :- m_free(P,C,T), not m_vortox(P,C,T), not sober_healthy(P,T).
info_mode(P,C,T,free) :- m_free(P,C,T), shadow_token(P,C,T).
info_mode(P,C,T,base) :- token_due(P,C,T,_), not m_free(P,C,T), not m_vortox(P,C,T).

enforce_true(P,C,T)  :- info_mode(P,C,T,base).
enforce_false(P,C,T) :- info_mode(P,C,T,all_false).

% ================= claim library =================
% Each schema: token generation (ST choice), atomic-claim truth, constraints.
% Sites carry the ability instance so red herrings / jinxes can scope.

% ---- among2(Team): washerwoman/librarian/investigator ----
0 { shown_none(P,C,T) } 1 :- token_due(P,C,T,among2(TM)).
1 { shown_among2(P,C,T,CC,Q1,Q2) : role(CC,TM,_), in_pool(CC),
      player(Q1), player(Q2), Q1 < Q2, Q1 != P, Q2 != P } 1 :-
    token_due(P,C,T,among2(TM)), not shown_none(P,C,T).
% "none" is only offered by the librarian (no outsiders)
:- shown_none(P,C,T), token_due(P,C,T,among2(TM)), TM != outsider.

site_ch(am2(P,C,T,Q),Q,T) :- shown_among2(P,C,T,_,Q1,Q2), Q = Q1.
site_ch(am2(P,C,T,Q),Q,T) :- shown_among2(P,C,T,_,Q1,Q2), Q = Q2.
am2_true(P,C,T) :- shown_among2(P,C,T,CC,Q1,Q2), reg_char(Q1,CC,am2(P,C,T,Q1)).
am2_true(P,C,T) :- shown_among2(P,C,T,CC,Q1,Q2), reg_char(Q2,CC,am2(P,C,T,Q2)).
% none-claim truth: no player registers as any outsider
site_ch(am2n(P,C,T,Q),Q,T) :- shown_none(P,C,T), player(Q).
none_false(P,C,T) :- shown_none(P,C,T), player(Q), in_pool(CC),
                     role(CC,outsider,_), reg_char(Q,CC,am2n(P,C,T,Q)).
:- enforce_true(P,C,T),  shown_among2(P,C,T,_,_,_), not am2_true(P,C,T).
:- enforce_false(P,C,T), am2_true(P,C,T).
:- enforce_true(P,C,T),  none_false(P,C,T).
:- enforce_false(P,C,T), shown_none(P,C,T), not none_false(P,C,T).

% ---- count_pairs_evil: chef ----
% Sites are PER PAIR (per atomic evaluation occurrence): the Recluse can
% register evil for one adjacency pair and good for the other in one check.
1 { shown_num(P,C,T,K) : K = 0..7 } 1 :- token_due(P,C,T,count_pairs_evil).
site_al(chefp(P,T,Q1,Q2,Q1),Q1,T) :-
    token_due(P,chef,T,count_pairs_evil), succ_seat(Q1,Q2).
site_al(chefp(P,T,Q1,Q2,Q2),Q2,T) :-
    token_due(P,chef,T,count_pairs_evil), succ_seat(Q1,Q2).
chef_pair(P,T,Q1) :- token_due(P,chef,T,count_pairs_evil), succ_seat(Q1,Q2),
    reg_evil(Q1,chefp(P,T,Q1,Q2,Q1)), reg_evil(Q2,chefp(P,T,Q1,Q2,Q2)).
chef_actual(P,T,K) :- token_due(P,chef,T,count_pairs_evil),
    K = #count{ Q1 : chef_pair(P,T,Q1) }.
:- enforce_true(P,chef,T), shown_num(P,chef,T,K), chef_actual(P,T,K2), K != K2.
:- enforce_false(P,chef,T), shown_num(P,chef,T,K), chef_actual(P,T,K).

% ---- count_evil_neighbors: empath ----
1 { shown_num(P,C,T,K) : K = 0..2 } 1 :- token_due(P,C,T,count_evil_neighbors).
site_al(emp(P,T,Q),Q,T) :- token_due(P,empath,T,count_evil_neighbors),
                           alive_neighbor(P,Q,T).
emp_actual(P,T,K) :- token_due(P,empath,T,count_evil_neighbors),
    K = #count{ Q : alive_neighbor(P,Q,T), reg_evil(Q,emp(P,T,Q)) }.
:- enforce_true(P,empath,T), shown_num(P,empath,T,K), emp_actual(P,T,K2), K != K2.
:- enforce_false(P,empath,T), shown_num(P,empath,T,K), emp_actual(P,T,K).

% ---- yesno_demon_among2: fortune teller ----
1 { shown_bool(P,C,T,yes) ; shown_bool(P,C,T,no) } 1 :-
    token_due(P,C,T,yesno_demon_among2).
site_dm(ftq(P,T,Q),Q,T) :- token_due(P,fortuneteller,T,yesno_demon_among2),
                           picked2(P,fortuneteller,T,Q,_).
site_dm(ftq(P,T,Q),Q,T) :- token_due(P,fortuneteller,T,yesno_demon_among2),
                           picked2(P,fortuneteller,T,_,Q).
ft_site(ftq(P,T,Q)) :- site_dm(ftq(P,T,Q),Q,T).
ft_yes(P,T) :- picked2(P,fortuneteller,T,Q1,Q2), reg_demon(Q1,ftq(P,T,Q1)).
ft_yes(P,T) :- picked2(P,fortuneteller,T,Q1,Q2), reg_demon(Q2,ftq(P,T,Q2)).
:- enforce_true(P,fortuneteller,T), shown_bool(P,fortuneteller,T,yes), not ft_yes(P,T).
:- enforce_true(P,fortuneteller,T), shown_bool(P,fortuneteller,T,no), ft_yes(P,T).
:- enforce_false(P,fortuneteller,T), shown_bool(P,fortuneteller,T,yes), ft_yes(P,T).
:- enforce_false(P,fortuneteller,T), shown_bool(P,fortuneteller,T,no), not ft_yes(P,T).

% ---- char_of_executee: undertaker ----
1 { shown_char(P,C,T,CC) : in_pool(CC) } 1 :-
    token_due(P,C,T,char_of_executee), executed_yesterday(_,T).
site_ch(und(P,T,Q),Q,T) :- token_due(P,undertaker,T,char_of_executee),
                           executed_yesterday(Q,T).
und_true(P,T) :- shown_char(P,undertaker,T,CC), executed_yesterday(Q,T),
                 reg_char(Q,CC,und(P,T,Q)).
:- enforce_true(P,undertaker,T), shown_char(P,undertaker,T,_), not und_true(P,T).
:- enforce_false(P,undertaker,T), und_true(P,T).

% ---- char_of_picked: ravenkeeper (wired via on-death trigger in mech) ----
1 { shown_char(P,C,T,CC) : in_pool(CC) } 1 :- token_due(P,C,T,char_of_picked).
site_ch(rvk(P,T,Q),Q,T) :- token_due(P,ravenkeeper,T,char_of_picked),
                           picked(P,ravenkeeper,T,Q).
rvk_true(P,T) :- shown_char(P,ravenkeeper,T,CC), picked(P,ravenkeeper,T,Q),
                 reg_char(Q,CC,rvk(P,T,Q)).
:- enforce_true(P,ravenkeeper,T), shown_char(P,ravenkeeper,T,_), not rvk_true(P,T).
:- enforce_false(P,ravenkeeper,T), rvk_true(P,T).

% ---- grandchild: grandmother ----
1 { grandchild(P,Q) : player(Q), Q != P } 1 :- initial(P,grandmother).
:- grandchild(P,Q), align(Q,evil,1).
1 { shown_gm(P,T,Q,CC) : in_pool(CC), player(Q) } 1 :-
    token_due(P,grandmother,T,grandchild).
site_ch(gm(P,T,Q),Q,T) :- token_due(P,grandmother,T,grandchild), grandchild(P,Q).
gm_true(P,T) :- shown_gm(P,T,Q,CC), grandchild(P,Q), reg_char(Q,CC,gm(P,T,Q)).
:- enforce_true(P,grandmother,T), shown_gm(P,T,_,_), not gm_true(P,T).
:- enforce_false(P,grandmother,T), gm_true(P,T).

% ---- woke_count2: chambermaid ----
1 { shown_num(P,C,T,K) : K = 0..2 } 1 :- token_due(P,C,T,woke_count2).
cm_woke(P,T,Q) :- picked2(P,chambermaid,T,Q,_), woke(Q,T).
cm_woke(P,T,Q) :- picked2(P,chambermaid,T,_,Q), woke(Q,T).
cm_actual(P,T,K) :- token_due(P,chambermaid,T,woke_count2),
    picked2(P,chambermaid,T,_,_), K = #count{ Q : cm_woke(P,T,Q) }.
:- enforce_true(P,chambermaid,T), shown_num(P,chambermaid,T,K),
   cm_actual(P,T,K2), K != K2.
:- enforce_false(P,chambermaid,T), shown_num(P,chambermaid,T,K), cm_actual(P,T,K).

% ---- steps_demon_minion: clockmaker ----
1 { shown_num(P,C,T,K) : K = 1..7 } 1 :- token_due(P,C,T,steps_demon_minion).
seatdist_min(P,Q,D) :- player(P), player(Q), P != Q,
    D = #min{ N : walk(P,Q,N) ; N : walkc(P,Q,N) }.
clk_actual(P,T,K) :- token_due(P,clockmaker,T,steps_demon_minion),
    initial(QD,CD), team_of(CD,demon),
    K = #min{ D : seatdist_min(QD,QM,D), initial(QM,CM), team_of(CM,minion) }.
:- enforce_true(P,clockmaker,T), shown_num(P,clockmaker,T,K),
   clk_actual(P,T,K2), K != K2.
:- enforce_false(P,clockmaker,T), shown_num(P,clockmaker,T,K), clk_actual(P,T,K).

% ---- dreamer_pair ----
1 { shown_dreamer(P,T,GC,EC) : role(GC,GT,_), good_team(GT), in_pool(GC),
      role(EC,ET,_), evil_team(ET), in_pool(EC) } 1 :-
    token_due(P,dreamer,T,dreamer_pair).
site_ch(drm(P,T,Q),Q,T) :- token_due(P,dreamer,T,dreamer_pair),
                           picked(P,dreamer,T,Q).
drm_true(P,T) :- shown_dreamer(P,T,GC,_), picked(P,dreamer,T,Q),
                 reg_char(Q,GC,drm(P,T,Q)).
drm_true(P,T) :- shown_dreamer(P,T,_,EC), picked(P,dreamer,T,Q),
                 reg_char(Q,EC,drm(P,T,Q)).
:- enforce_true(P,dreamer,T), shown_dreamer(P,T,_,_), not drm_true(P,T).
:- enforce_false(P,dreamer,T), drm_true(P,T).

% ---- malfunction_count: mathematician ----
% "Working abnormally" covers: Vortox-falsified townsfolk, and ANY token
% received in FREE mode (impairment or charade) — including death-triggered
% tokens like a poisoned Sage's (NQT #34). The mathematician's own token is
% not self-counted.
malfunctioned(Q,T) :- info_mode(Q,C,T,all_false).
malfunctioned(Q,T) :- token_due(Q,C,T,_), info_mode(Q,C,T,free).
1 { shown_num(P,C,T,K) : K = 0..15 } 1 :- token_due(P,C,T,malfunction_count).
math_actual(P,T,K) :- token_due(P,mathematician,T,malfunction_count),
    K = #count{ Q : malfunctioned(Q,T), Q != P }.
:- enforce_true(P,mathematician,T), shown_num(P,mathematician,T,K),
   math_actual(P,T,K2), K != K2.
:- enforce_false(P,mathematician,T), shown_num(P,mathematician,T,K),
   math_actual(P,T,K).

% ---- yesno over day events: flowergirl (demon voted), towncrier (minion nominated) ----
1 { shown_bool(P,C,T,yes) ; shown_bool(P,C,T,no) } 1 :-
    token_due(P,C,T,yesno_day(_)).
site_dm(flg(P,T,Q),Q,T) :- token_due(P,flowergirl,T,yesno_day(demon_voted)),
                           voted(Q,D), T = D+1.
flg_yes(P,T) :- token_due(P,flowergirl,T,yesno_day(demon_voted)),
                voted(Q,D), T = D+1, reg_demon(Q,flg(P,T,Q)).
site_tm(tcr(P,T,Q),Q,T) :- token_due(P,towncrier,T,yesno_day(minion_nominated)),
                           nominated(Q,_,D), T = D+1.
tcr_yes(P,T) :- token_due(P,towncrier,T,yesno_day(minion_nominated)),
                nominated(Q,_,D), T = D+1, reg_team(Q,minion,tcr(P,T,Q)).
day_yes(P,flowergirl,T) :- flg_yes(P,T).
day_yes(P,towncrier,T) :- tcr_yes(P,T).
:- enforce_true(P,C,T), token_due(P,C,T,yesno_day(_)),
   shown_bool(P,C,T,yes), not day_yes(P,C,T).
:- enforce_true(P,C,T), token_due(P,C,T,yesno_day(_)),
   shown_bool(P,C,T,no), day_yes(P,C,T).
:- enforce_false(P,C,T), token_due(P,C,T,yesno_day(_)),
   shown_bool(P,C,T,yes), day_yes(P,C,T).
:- enforce_false(P,C,T), token_due(P,C,T,yesno_day(_)),
   shown_bool(P,C,T,no), not day_yes(P,C,T).

% ---- count_dead_evil: oracle ----
1 { shown_num(P,C,T,K) : K = 0..15 } 1 :- token_due(P,C,T,count_dead_evil).
site_al(orc(P,T,Q),Q,T) :- token_due(P,oracle,T,count_dead_evil), app_dead(Q,T).
orc_actual(P,T,K) :- token_due(P,oracle,T,count_dead_evil),
    K = #count{ Q : app_dead(Q,T), reg_evil(Q,orc(P,T,Q)) }.
:- enforce_true(P,oracle,T), shown_num(P,oracle,T,K), orc_actual(P,T,K2), K != K2.
:- enforce_false(P,oracle,T), shown_num(P,oracle,T,K), orc_actual(P,T,K).

% ---- same_alignment_yesno: seamstress (once) ----
1 { shown_bool(P,C,T,yes) ; shown_bool(P,C,T,no) } 1 :-
    token_due(P,C,T,same_alignment_yesno).
site_al(sea(P,T,Q),Q,T) :- token_due(P,seamstress,T,same_alignment_yesno),
                           picked2(P,seamstress,T,Q,_).
site_al(sea(P,T,Q),Q,T) :- token_due(P,seamstress,T,same_alignment_yesno),
                           picked2(P,seamstress,T,_,Q).
sea_same(P,T) :- picked2(P,seamstress,T,Q1,Q2),
    reg_evil(Q1,sea(P,T,Q1)), reg_evil(Q2,sea(P,T,Q2)).
sea_same(P,T) :- picked2(P,seamstress,T,Q1,Q2),
    reg_good(Q1,sea(P,T,Q1)), reg_good(Q2,sea(P,T,Q2)).
:- enforce_true(P,seamstress,T), shown_bool(P,seamstress,T,yes), not sea_same(P,T).
:- enforce_true(P,seamstress,T), shown_bool(P,seamstress,T,no), sea_same(P,T).
:- enforce_false(P,seamstress,T), shown_bool(P,seamstress,T,yes), sea_same(P,T).
:- enforce_false(P,seamstress,T), shown_bool(P,seamstress,T,no), not sea_same(P,T).

% ---- juggle_count: juggler ----
% juggles are day inputs: juggle(P, Target, GuessChar, D)
1 { shown_num(P,C,T,K) : K = 0..5 } 1 :- token_due(P,C,T,juggle_count).
site_ch(jug(P,D,Q),Q,D) :- juggle(P,Q,_,D).
site_day(jug(P,D,Q)) :- site_ch(jug(P,D,Q),Q,D).
jug_correct(P,Q,D) :- juggle(P,Q,GC,D), reg_char(Q,GC,jug(P,D,Q)).
jug_actual(P,T,K) :- token_due(P,juggler,T,juggle_count), T = D+1, day(D),
    K = #count{ Q : jug_correct(P,Q,D) }.
:- enforce_true(P,juggler,T), shown_num(P,juggler,T,K), jug_actual(P,T,K2), K != K2.
:- enforce_false(P,juggler,T), shown_num(P,juggler,T,K), jug_actual(P,T,K).

% ---- sage_pair: on demon-death (wired in mech) ----
1 { shown_pair(P,C,T,Q1,Q2) : player(Q1), player(Q2), Q1 < Q2 } 1 :-
    token_due(P,C,T,sage_pair).
sage_true(P,T) :- shown_pair(P,sage,T,QD,_), sage_killer(P,T,QD).
sage_true(P,T) :- shown_pair(P,sage,T,_,QD), sage_killer(P,T,QD).
:- enforce_true(P,sage,T), shown_pair(P,sage,T,_,_), not sage_true(P,T).
:- enforce_false(P,sage,T), sage_true(P,T).

% ---- freeform statements: savant / artist / gossip truth checks ----
% The instance/compiler emits: stmt(Id, P, C, T) declaring a statement token
% and stmt_true(Id) :- <body>. Savant pattern: exactly one of the pair true.
savant_pair(P,T,Id1,Id2) :- stmt(Id1,P,savant,T), stmt(Id2,P,savant,T), Id1 < Id2.
sv_ok(P,T) :- savant_pair(P,T,Id1,Id2), stmt_true(Id1), not stmt_true(Id2).
sv_ok(P,T) :- savant_pair(P,T,Id1,Id2), stmt_true(Id2), not stmt_true(Id1).
:- enforce_true(P,savant,T2), savant_pair(P,T,_,_), day_of_token(P,savant,T,T2),
   not sv_ok(P,T).
% vortox: both statements false
:- enforce_false(P,savant,T2), day_of_token(P,savant,T,T2),
   savant_pair(P,T,Id1,Id2), stmt_true(Id1).
:- enforce_false(P,savant,T2), day_of_token(P,savant,T,T2),
   savant_pair(P,T,Id1,Id2), stmt_true(Id2).
day_of_token(P,C,T,T) :- stmt(_,P,C,T).
% savant day visits: token_due comes from the day visit input
token_due(P,savant,T,savant_visit) :- stmt(_,P,savant,T), has_ability(P,savant,T).

% ---- outsiders_in_play: godfather (night 1) ----
% Shown set must equal the set of outsider characters some player registers
% as (per-player sites: the Spy may appear as an outsider, the Recluse's
% outsider identity may be hidden... no — recluse registers evil-side only;
% the direction that matters: spy adds, and a dead outsider still counts).
{ shown_gf(P,T,CC) : role(CC,outsider,_), in_pool(CC) } :-
    token_due(P,godfather,T,outsiders_in_play).
site_ch(gf(P,T,Q),Q,T) :- token_due(P,godfather,T,outsiders_in_play), player(Q).
gf_reg(P,T,CC) :- token_due(P,godfather,T,outsiders_in_play),
    role(CC,outsider,_), in_pool(CC), player(Q), reg_char(Q,CC,gf(P,T,Q)).
:- enforce_true(P,godfather,T), shown_gf(P,T,CC), not gf_reg(P,T,CC).
:- enforce_true(P,godfather,T), gf_reg(P,T,CC), not shown_gf(P,T,CC).
gf_mismatch(P,T) :- shown_gf(P,T,CC), not gf_reg(P,T,CC).
gf_mismatch(P,T) :- gf_reg(P,T,CC), not shown_gf(P,T,CC).
:- enforce_false(P,godfather,T), not gf_mismatch(P,T),
   token_due(P,godfather,T,outsiders_in_play).
