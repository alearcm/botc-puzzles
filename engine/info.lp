%%% info.lp — registration, tokens, the claim library, truth-pattern modes.

% ================= registration =================
% Sites are opaque terms created by claim rules. reg atoms exist per site.
% Misregistration is part of the misregistering character's ability: it
% requires that character to be functioning at evaluation time.

% --- alignment registration ---
% subjects that MAY register evil (recluse) / good (spy)
% NOTE: deliberately no aliveness requirement — the executed Recluse may
% register as the Imp to the Undertaker (Recluse almanac, T0). Whether
% droison strips misregistration is itself a seam; current default: it does.
may_misreg_evil(Q,T) :- char(Q,recluse,T), not impaired_at(Q,T,99).
may_misreg_good(Q,T) :- char(Q,spy,T), not impaired_at(Q,T,99).

0 { mr_evil(Q,Site) } 1 :- site_al(Site,Q,T), align(Q,good,T), may_misreg_evil(Q,T).
0 { mr_good(Q,Site) } 1 :- site_al(Site,Q,T), align(Q,evil,T), may_misreg_good(Q,T).

reg_evil(Q,Site) :- site_al(Site,Q,T), align(Q,evil,T), not mr_good(Q,Site).
reg_evil(Q,Site) :- mr_evil(Q,Site).
reg_good(Q,Site) :- site_al(Site,Q,T), not reg_evil(Q,Site).

% --- character registration ---
% default: actual character; recluse may register as any script minion/demon;
% spy as any script townsfolk/outsider.
0 { mr_char(Q,Site,CC) : role(CC,TM,_), on_script(CC), evil_team(TM) } 1 :-
    site_ch(Site,Q,T), may_misreg_evil(Q,T).
0 { mr_char(Q,Site,CC) : role(CC,TM,_), on_script(CC), good_team(TM) } 1 :-
    site_ch(Site,Q,T), may_misreg_good(Q,T).
reg_char(Q,CC,Site) :- mr_char(Q,Site,CC).
reg_char(Q,CC,Site) :- site_ch(Site,Q,T), char(Q,CC,T), not mr_char(Q,Site,_).

% --- demon registration (fortune teller / slayer style checks) ---
reg_demon(Q,Site) :- site_dm(Site,Q,T), char(Q,C,T), team_of(C,demon).
% red herring: one good player registers as demon to the fortune teller
1 { red_herring(Q) : player(Q) } 1 :- in_play(fortuneteller).
:- red_herring(Q), initial(Q,C), team_of(C,TM), evil_team(TM).
reg_demon(Q,Site) :- site_dm(Site,Q,T), red_herring(Q), ft_site(Site).
0 { mr_demon(Q,Site) } 1 :- site_dm(Site,Q,T), may_misreg_evil(Q,T).
reg_demon(Q,Site) :- mr_demon(Q,Site).

% --- team registration (virgin's townsfolk check, towncrier's minion check) ---
reg_team(Q,TM,Site) :- site_tm(Site,Q,T), char(Q,C,T), team_of(C,TM),
                       not mr_team(Q,Site,_).
0 { mr_team(Q,Site,TM) : good_team(TM) } 1 :- site_tm(Site,Q,T), may_misreg_good(Q,T).
0 { mr_team(Q,Site,TM) : evil_team(TM) } 1 :- site_tm(Site,Q,T), may_misreg_evil(Q,T).
reg_team(Q,TM,Site) :- mr_team(Q,Site,TM).

% ================= tokens & modes =================
% learns(C, first|other|each, Schema) from cards.
token_due(P,C,T,Schema) :- learns(C,first,Schema), acting(P,C,T), T = 1.
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
m_free(P,C,T) :- token_due(P,C,T,_), sched(C,T,I), impaired_at(P,T,I).
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
1 { shown_among2(P,C,T,CC,Q1,Q2) : role(CC,TM,_), on_script(CC),
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
none_false(P,C,T) :- shown_none(P,C,T), player(Q), on_script(CC),
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
1 { shown_char(P,C,T,CC) : on_script(CC) } 1 :-
    token_due(P,C,T,char_of_executee), executed_yesterday(_,T).
site_ch(und(P,T,Q),Q,T) :- token_due(P,undertaker,T,char_of_executee),
                           executed_yesterday(Q,T).
und_true(P,T) :- shown_char(P,undertaker,T,CC), executed_yesterday(Q,T),
                 reg_char(Q,CC,und(P,T,Q)).
:- enforce_true(P,undertaker,T), shown_char(P,undertaker,T,_), not und_true(P,T).
:- enforce_false(P,undertaker,T), und_true(P,T).

% ---- char_of_picked: ravenkeeper (wired via on-death trigger in mech) ----
1 { shown_char(P,C,T,CC) : on_script(CC) } 1 :- token_due(P,C,T,char_of_picked).
site_ch(rvk(P,T,Q),Q,T) :- token_due(P,ravenkeeper,T,char_of_picked),
                           picked(P,ravenkeeper,T,Q).
rvk_true(P,T) :- shown_char(P,ravenkeeper,T,CC), picked(P,ravenkeeper,T,Q),
                 reg_char(Q,CC,rvk(P,T,Q)).
:- enforce_true(P,ravenkeeper,T), shown_char(P,ravenkeeper,T,_), not rvk_true(P,T).
:- enforce_false(P,ravenkeeper,T), rvk_true(P,T).

% ---- grandchild: grandmother ----
1 { grandchild(P,Q) : player(Q), Q != P } 1 :- initial(P,grandmother).
:- grandchild(P,Q), align(Q,evil,1).
1 { shown_gm(P,T,Q,CC) : on_script(CC), player(Q) } 1 :-
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
1 { shown_dreamer(P,T,GC,EC) : role(GC,GT,_), good_team(GT), on_script(GC),
      role(EC,ET,_), evil_team(ET), on_script(EC) } 1 :-
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
1 { shown_num(P,C,T,K) : K = 0..15 } 1 :- token_due(P,C,T,malfunction_count).
math_actual(P,T,K) :- token_due(P,mathematician,T,malfunction_count),
    K = #count{ Q : malfunctioned(Q,T) }.
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
token_due(P,savant,T,savant_visit) :- stmt(_,P,savant,T), char(P,savant,T).
