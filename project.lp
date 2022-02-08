% Insurance Referee Assignment
% Ian Bolton

%%%%%%%%%%%%%
% Rules
%%%%%%%%%%%%%
% only show assign predicate
#show assign/2.

% assign a case to a referee.
% more than one case may be assigned to a single referee,
% but each case may only be assigned once
{assign(C, R): referee(R, T, MW, PW, PP)}=1 :- case(C, T1, E, D, PC, PP1).

%%%%%%%%%%%%%%%%%%
% Hard Constraints
%%%%%%%%%%%%%%%%%%
% assigned case cannot cause workload to exceed maximum.
actual_workload(S, R) :- S = #sum{E: assign(C, R1), case(C, T, E, D, PC, PP), referee(R1, T1, MW, PW, PP1)}, referee(R, T1, MW, PW, PP1), R=R1.
:- assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), actual_workload(S, R), S > MW.

% case cant be assigned to a referee with region preference of 0.
:- assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), prefRegion(R1, PC1, P), R=R1, PC=PC1, P=0.

% case cant be assigned to a referee with type preference of 0.
:- assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), prefType(R1, T2, P), R=R1, T=T2, P=0.

% cases over a threshold has to be assigned to internal (i) referees
:- assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), externalMaxDamage(D1), D>D1, T1=e.

%%%%%%%%%%%%%%%%%%
% Weak Constraints
%%%%%%%%%%%%%%%%%%
%c = 16*cA + 7*cB + 9*cC + 34*cD + 34*cE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CA
% The sum of all payments of cases to external referees should be minimized.
external_sum(S) :- S = #sum{PP: assign(C, R), case(C, T, E, D, PC, PP), referee(R, e, MW, PW, PP1)}.
#minimize{S@4: external_sum(S)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CB
% sum all external referee's previous payment(s)
prev_payment(O) :- O = #sum{PP, R: referee(R, e, MW, PW, PP)}.

% add case_payment O to referee's previous payment, PP1
o_rid(O, R) :- referee(R, e, MW, PW, PP1), S = #sum{PP: case(C, T, E, D, PC, PP), assign(C, R), referee(R, e, MW, PW, PP1)}, R=R1, O = S + PP1.

% calculate avg external payment
avg_numerator(A) :- A = #sum{O: prev_payment(O)}.
avg_denominator(B) :- B = #count{R: referee(R, e, MW, PW, PP1)}.
avg_payment(AP) :- AP = A/B, avg_numerator(A), avg_denominator(B).

% sum |avg - o_rid| costs
cost(C, R) :- C = |AP - O|, avg_payment(AP), o_rid(O, R), referee(R1, T, MW, PW, PP1), R=R1.

% calculating CB does not work. something to do with avg_payment or o_rid calculation?
cost_sum(CB) :- CB = #sum{C,R: cost(C,R), referee(R, e, MW, PW, PP1)}.

% for some reason, :~ wasnt minimizing the cost_sum enough, so I switched it to #minimize
#minimize{CB@3: cost_sum(CB)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CC
%sum of all workloads (E) of cases to be assigned
case_workload(CW) :- CW = #sum{E: case(C, T, E, D, PC, PP)}.
%sum case workloads with referee R's previous workload
w_rid(W, R) :- referee(R, T1, MW, PW, PP1), S = #sum{E: case(C, T, E, D, PC, PP), assign(C, R), referee(R, T1, MW, PW, PP1)}, R=R1, W = S + PW.

% calculate average overall workload
% sum overall workload of each referee
w_numerator(A) :- A = #sum{PW,R: referee(R, T1, MW, PW, PP1)}.
% count number of referees
w_denominator(B) :- B = #count{R: referee(R, T1, MW, PW, PP1)}.
% divide total overall workload over the number of referees
w_avg(AW) :- AW = A/B, w_numerator(A), w_denominator(B).

% calculate divergence of referee's overall workload with average overall workload
balance_workload(O, R) :- O = |AW - W|, w_avg(AW), w_rid(W, R), referee(R1, T, MW, PW, PP1), R=R1.
% sum these divergences and attempt to minimize them
w_sum(CC) :- CC = #sum{O,R: balance_workload(O,R), referee(R, T1, MW, PW, PP1)}.
#minimize{CC: w_sum(CC)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CD
% Referees should handle types of cases with higher preference.
type_constraint(S) :- S = #sum{CD: assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), prefType(R, T, P), CD = 3 - P}.
#minimize{S@1: type_constraint(S)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CE
% Referees should handle types of cases in regions with higher preference.
region_constraint(S) :- S = #sum{CE: assign(C, R), case(C, T, E, D, PC, PP), referee(R, T1, MW, PW, PP1), prefRegion(R, PC, P), CE = 3 - P}.
#minimize{S@0: region_constraint(S)}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%