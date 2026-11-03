:- style_check(-singleton).

step1_fol([
    all(X, all(R, imp(and(archivist(X), verifies(X, R)), trusted(X)))),
    all(X, all(R, imp(and(trusted(X), and(has_access(X, R), sealed(R))), can_inspect(X, R)))),
    all(X, all(R, imp(and(inspects(X, R), finds_mark(X, R)), verifies(X, R)))),
    all(R, imp(in_archive(R), sealed(R))),
    in_archive(scroll_7),
    has_access(mira, scroll_7),
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7)),
    archivist(mira)
]).

step2_neg_goal(neg(trusted(mira))).

step3_no_imp([
    all(X, all(R, or(neg(and(archivist(X), verifies(X, R))), trusted(X)))),
    all(X, all(R, or(neg(and(trusted(X), and(has_access(X, R), sealed(R)))), can_inspect(X, R)))),
    all(X, all(R, or(neg(and(inspects(X, R), finds_mark(X, R))), verifies(X, R)))),
    all(R, or(neg(in_archive(R)), sealed(R))),
    in_archive(scroll_7),
    has_access(mira, scroll_7),
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7)),
    archivist(mira),
    neg(trusted(mira))
]).

step4_neg_in([
    all(X, all(R, or(or(neg(archivist(X)), neg(verifies(X, R))), trusted(X)))),
    all(X, all(R, or(or(neg(trusted(X)), or(neg(has_access(X, R)), neg(sealed(R)))), can_inspect(X, R)))),
    all(X, all(R, or(or(neg(inspects(X, R)), neg(finds_mark(X, R))), verifies(X, R)))),
    all(R, or(neg(in_archive(R)), sealed(R))),
    in_archive(scroll_7),
    has_access(mira, scroll_7),
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7)),
    archivist(mira),
    neg(trusted(mira))
]).

step5_std_vars([
    all(X1, all(R1, or(or(neg(archivist(X1)), neg(verifies(X1, R1))), trusted(X1)))),
    all(X2, all(R2, or(or(neg(trusted(X2)), or(neg(has_access(X2, R2)), neg(sealed(R2)))), can_inspect(X2, R2)))),
    all(X3, all(R3, or(or(neg(inspects(X3, R3)), neg(finds_mark(X3, R3))), verifies(X3, R3)))),
    all(R4, or(neg(in_archive(R4)), sealed(R4))),
    in_archive(scroll_7),
    has_access(mira, scroll_7),
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7)),
    archivist(mira),
    neg(trusted(mira))
]).

step6_skolem([
    or(or(neg(archivist(X1)), neg(verifies(X1, R1))), trusted(X1)),
    or(or(neg(trusted(X2)), or(neg(has_access(X2, R2)), neg(sealed(R2)))), can_inspect(X2, R2)),
    or(or(neg(inspects(X3, R3)), neg(finds_mark(X3, R3))), verifies(X3, R3)),
    or(neg(in_archive(R4)), sealed(R4)),
    in_archive(scroll_7),
    has_access(mira, scroll_7),
    and(inspects(mira, scroll_7), finds_mark(mira, scroll_7)),
    archivist(mira),
    neg(trusted(mira))
]).

step7_cnf([
    clause(c1, [neg(archivist(X1)), neg(verifies(X1, R1)), pos(trusted(X1))]),
    clause(c2, [neg(trusted(X2)), neg(has_access(X2, R2)), neg(sealed(R2)), pos(can_inspect(X2, R2))]),
    clause(c3, [neg(inspects(X3, R3)), neg(finds_mark(X3, R3)), pos(verifies(X3, R3))]),
    clause(c4, [neg(in_archive(R4)), pos(sealed(R4))]),
    clause(c5, [pos(in_archive(scroll_7))]),
    clause(c6, [pos(has_access(mira, scroll_7))]),
    clause(c7a, [pos(inspects(mira, scroll_7))]),
    clause(c7b, [pos(finds_mark(mira, scroll_7))]),
    clause(c8, [pos(archivist(mira))]),
    clause(c9, [neg(trusted(mira))])
]).

opp(pos(P), neg(P)).
opp(neg(P), pos(P)).

resolve_pair(C1, C2, Resolvent) :-
    copy_term(C1, L1),
    copy_term(C2, L2),
    select(Lit1, L1, Rem1),
    select(Lit2, L2, Rem2),
    opp(Lit1, Comp),
    unify_with_occurs_check(Lit2, Comp),
    append(Rem1, Rem2, Raw),
    list_to_set(Raw, Resolvent).

get_clause(Id, Clauses, Lits) :-
    member(clause(Id, Lits), Clauses).

show_clause(Label, C) :-
    copy_term(C, Copy),
    numbervars(Copy, 0, _),
    format('  ~w~p~n', [Label, Copy]).

step8_resolve :-
    step7_cnf(Base),
    writeln('=== STEP 7: Initial CNF Clauses ==='),
    forall(member(clause(Id, C), Base), (
        atom_concat(Id, ' : ', Lbl),
        show_clause(Lbl, C)
    )),
    writeln('\n=== STEP 8: Resolution Refutation Derivation ==='),
    get_clause(c9, Base, L_c9),
    get_clause(c1, Base, L_c1),
    resolve_pair(L_c9, L_c1, R1),
    show_clause('1. Resolve c9 and c1  -> r1 : ', R1),
    get_clause(c8, Base, L_c8),
    resolve_pair(R1, L_c8, R2),
    show_clause('2. Resolve r1 and c8  -> r2 : ', R2),
    get_clause(c3, Base, L_c3),
    resolve_pair(R2, L_c3, R3),
    show_clause('3. Resolve r2 and c3  -> r3 : ', R3),
    get_clause(c7a, Base, L_c7a),
    resolve_pair(R3, L_c7a, R4),
    show_clause('4. Resolve r3 and c7a -> r4 : ', R4),
    get_clause(c7b, Base, L_c7b),
    resolve_pair(R4, L_c7b, R5),
    show_clause('5. Resolve r4 and c7b -> r5 : ', R5),
    (R5 == [] ->
        writeln('\nResult: Empty clause [] derived! Contradiction reached.'),
        writeln('Conclusion Verified: trusted(mira) holds.')
    ;
        writeln('Failed to derive empty clause.')
    ).

run_proof :-
    step8_resolve.

main :-
    run_proof,
    halt.

main(_) :-
    run_proof,
    halt.

:- initialization(run_proof).
