:- module(spatial_logic,
    [ calculate_clean_minkowski_sum/3,
      check_dynamic_collision/3,
      create_polygon/3,
      free_polygon/1,
      create_layer/2,
      free_layer/1
    ]).

% Point(X, Y)
% Polygon(Vertices, IsConvex, ZoneName, NumVertices)
% Layer(Polygons, LayerName, PolygonCount)

% create_polygon(+Vertices, +ZoneName, -Polygon)
% Also accepts the argument order create_polygon(+ZoneName, +Vertices, -Polygon).
create_polygon(A, B, Polygon) :-
    is_list(A),
    !,
    build_polygon(A, B, Polygon).
create_polygon(A, B, Polygon) :-
    is_list(B),
    build_polygon(B, A, Polygon).

build_polygon(Vertices, ZoneName, polygon(Vertices, IsConvex, ZoneName, N)) :-
    is_list(Vertices),
    maplist(valid_point, Vertices),
    length(Vertices, N),
    (   N >= 3,
        convex_ccw(Vertices)
    ->  IsConvex = true
    ;   IsConvex = false
    ).

valid_point(point(X, Y)) :-
    number(X),
    number(Y).

% Succeeds when every turn of the (cyclic) vertex list is a left turn or straight.
convex_ccw(Vs) :-
    Vs = [A, B|_],
    append(Vs, [A, B], Ext),
    \+ ( window(Ext, P, Q, R),
         orient(P, Q, R, V),
         V < 0 ).

window([P, Q, R|_], P, Q, R).
window([_|T], P, Q, R) :-
    window(T, P, Q, R).

% free_polygon(+Polygon): memory is managed by the Prolog runtime.
free_polygon(_).

% create_layer(+LayerName-Polygons, -Layer)
create_layer(Name-Polygons, layer(Polygons, Name, N)) :-
    is_list(Polygons),
    length(Polygons, N).

% free_layer(+Layer): memory is managed by the Prolog runtime.
free_layer(_).

% calculate_clean_minkowski_sum(+Poly1, +Poly2, -SumPolygon)
calculate_clean_minkowski_sum(P1, P2, polygon(Hull, true, minkowski(N1, N2), L)) :-
    polygon_data(P1, V1, N1),
    polygon_data(P2, V2, N2),
    minkowski_hull(V1, V2, Hull),
    length(Hull, L).

% Accepts polygon/4 terms or plain vertex lists of valid points.
polygon_data(T, V, Name) :-
    compound(T),
    T =.. [_, V|_],
    is_list(V),
    maplist(valid_point, V),
    (   T = polygon(_, _, N0, _)
    ->  Name = N0
    ;   Name = vertices
    ).
polygon_data(V, V, vertices) :-
    is_list(V),
    maplist(valid_point, V).

% Hull of all pairwise vertex sums: equals the Minkowski sum hull.
minkowski_hull(V1, V2, Hull) :-
    findall(point(X, Y),
            ( member(point(X1, Y1), V1),
              member(point(X2, Y2), V2),
              X is X1 + X2,
              Y is Y1 + Y2 ),
            Pts),
    convex_hull(Pts, Hull).

% convex_hull(+Points, -Hull): Andrew's monotone chain, CCW, no collinear points.
convex_hull(Points, Hull) :-
    sort(Points, Sorted),
    (   Sorted = [_, _, _|_]
    ->  chain(Sorted, [], LS),
        reverse(Sorted, RS),
        chain(RS, [], US),
        reverse(LS, A),
        reverse(US, U),
        append(A0, [_], A),
        append(U0, [_], U),
        append(A0, U0, Hull)
    ;   Hull = Sorted
    ).

chain([], S, S).
chain([P|Ps], S0, S) :-
    push_pt(P, S0, S1),
    chain(Ps, S1, S).

push_pt(P, [B, A|R], S) :-
    orient(A, B, P, V),
    V =< 0,
    !,
    push_pt(P, [A|R], S).
push_pt(P, S, [P|S]).

% orient(+O, +A, +B, -Cross): cross product of (A-O) and (B-O).
orient(point(OX, OY), point(AX, AY), point(BX, BY), V) :-
    V is (AX - OX) * (BY - OY) - (AY - OY) * (BX - OX).

% check_dynamic_collision(+Robot, +Obstacle, +Velocity)
% Velocity: any Name(VX, VY) term or [VX, VY] - displacement of the robot over
% the unit time step. The configuration-space obstacle is C = Obstacle (+) (-Robot);
% a collision occurs iff the segment [0, Velocity] meets C (closed sets).
check_dynamic_collision(Robot, Obstacle, Velocity) :-
    polygon_data(Robot, RV, _),
    polygon_data(Obstacle, OV, _),
    RV = [_|_],
    OV = [_|_],
    velocity_data(Velocity, VX, VY),
    neg_pts(RV, NR),
    minkowski_hull(OV, NR, K),
    Origin = point(0, 0),
    End = point(VX, VY),
    once( in_convex(K, Origin)
        ; in_convex(K, End)
        ; edges_of(K, Es),
          member(A-B, Es),
          seg_intersect(Origin, End, A, B)
        ).

velocity_data([X, Y], X, Y) :-
    number(X),
    number(Y),
    !.
velocity_data(V, X, Y) :-
    compound(V),
    V =.. [_, X, Y],
    number(X),
    number(Y).

neg_pts([], []).
neg_pts([point(X, Y)|T], [point(NX, NY)|NT]) :-
    NX is -X,
    NY is -Y,
    neg_pts(T, NT).

% Closed convex polygon membership (CCW, at least 3 vertices).
in_convex(K, P) :-
    K = [_, _, _|_],
    edges_of(K, Es),
    forall(member(A-B, Es), (orient(A, B, P, V), V >= 0)).

% Cyclic edge list of a vertex list. Degenerate cases yield A-A or A-B, B-A.
edges_of(Vs, Es) :-
    Vs = [F|_],
    append(Vs, [F], C),
    consec(C, Es).

consec([_], []) :- !.
consec([A, B|T], [A-B|Es]) :-
    consec([B|T], Es).

% Closed segment intersection test.
seg_intersect(P1, P2, P3, P4) :-
    orient(P1, P2, P3, O1),
    orient(P1, P2, P4, O2),
    orient(P3, P4, P1, O3),
    orient(P3, P4, P2, O4),
    (   O1 * O2 < 0, O3 * O4 < 0
    ->  true
    ;   O1 =:= 0, on_seg(P1, P2, P3)
    ;   O2 =:= 0, on_seg(P1, P2, P4)
    ;   O3 =:= 0, on_seg(P3, P4, P1)
    ;   O4 =:= 0, on_seg(P3, P4, P2)
    ).

% Point P lies within the bounding box of segment AB (used for collinear points).
on_seg(point(AX, AY), point(BX, BY), point(PX, PY)) :-
    PX >= min(AX, BX),
    PX =< max(AX, BX),
    PY >= min(AY, BY),
    PY =< max(AY, BY).
