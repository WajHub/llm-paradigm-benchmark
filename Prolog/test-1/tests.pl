:- use_module(spatial_logic).

approx_eq(A, B) :-
    Diff is abs(A - B),
    Diff < 0.001.

contains_point(polygon(Vertices, _, _, _), X, Y) :-
    member(point(PX, PY), Vertices),
    approx_eq(PX, X),
    approx_eq(PY, Y).

polygon_area(polygon(Vertices, _, _, _), Area) :-
    (   Vertices = []
    ->  Area = 0
    ;   append(_, [First], Vertices),
        append(Vertices, [First], Closed),
        polygon_area_pairs(Closed, 0, Area)
    ).

polygon_area_pairs([point(X1, Y1), point(X2, Y2) | Rest], Acc, Area) :-
    Acc1 is Acc + (X1 * Y2 - X2 * Y1),
    polygon_area_pairs([point(X2, Y2) | Rest], Acc1, Area).
polygon_area_pairs([_], Acc, Area) :-
    Area is 0.5 * Acc.

polygon_is_ccw(Poly) :-
    polygon_area(Poly, Area),
    Area > 1e-9.

polygon_has_no_collinear(polygon(Vertices, _, _, _)) :-
    length(Vertices, N),
    (   N < 3
    ->  true
    ;   
        \+ ( nth0(I, Vertices, A),
             J is (I + 1) mod N,
             K is (I + 2) mod N,
             nth0(J, Vertices, B),
             nth0(K, Vertices, C),
             A = point(AX, AY),
             B = point(BX, BY),
             C = point(CX, CY),
             Cross is (BX - AX) * (CY - AY) - (BY - AY) * (CX - AX),
             abs(Cross) =< 1e-6
           )
    ).

polygon_matches_expected(polygon(Vertices, _, _, _), Expected) :-
    length(Vertices, N1),
    length(Expected, N2),
    N1 =:= N2,
    forall(member(point(X, Y), Expected),
           ( member(point(PX, PY), Vertices),
             approx_eq(PX, X),
             approx_eq(PY, Y)
           )).

make_polygon(Points, Name, polygon(Points, true, Name, Count)) :-
    length(Points, Count).

run_test(Name, Goal, PassedCount0, PassedCount1, FailedTests0, FailedTests1) :-
    (   catch(call(Goal), _, fail)
    ->  format('[PASS] ~w~n', [Name]),
        PassedCount1 is PassedCount0 + 1,
        FailedTests1 = FailedTests0
    ;   format('[FAIL] ~w~n', [Name]),
        PassedCount1 = PassedCount0,
        FailedTests1 = [Name | FailedTests0]
    ).

test_algo_a_01_basic_squares :-
    make_polygon([point(0, 0), point(2, 0), point(2, 2), point(0, 2)], 'Z1', Poly1),
    make_polygon([point(0, 0), point(2, 0), point(2, 2), point(0, 2)], 'Z2', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    polygon_matches_expected(Result, [point(0, 0), point(4, 0), point(4, 4), point(0, 4)]),
    polygon_is_ccw(Result),
    polygon_has_no_collinear(Result).

test_algo_a_02_point_and_polygon :-
    make_polygon([point(5, 5)], 'Point', Poly1),
    make_polygon([point(0, 0), point(1, 0), point(0, 1)], 'Triangle', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    polygon_matches_expected(Result, [point(5, 5), point(6, 5), point(5, 6)]),
    polygon_is_ccw(Result),
    polygon_has_no_collinear(Result).

test_algo_a_03_collinear_simplification :-
    make_polygon([point(0, 0), point(2, 0), point(0, 2)], 'Tri1', Poly1),
    make_polygon([point(0, 0), point(2, 0), point(0, 2)], 'Tri2', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    polygon_matches_expected(Result, [point(0, 0), point(4, 0), point(0, 4)]),
    polygon_is_ccw(Result),
    polygon_has_no_collinear(Result).

test_algo_a_04_negative_coordinates :-
    make_polygon([point(-5, -5), point(-3, -5), point(-3, -3), point(-5, -3)], 'NegSq', Poly1),
    make_polygon([point(1, 1), point(2, 1), point(2, 2), point(1, 2)], 'PosSq', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    length(Vertices, 4),
    contains_point(Result, -4, -4),
    contains_point(Result, -1, -1),
    polygon_is_ccw(Result),
    polygon_has_no_collinear(Result).

test_algo_a_05_single_points :-
    make_polygon([point(-2.5, 3.5)], 'Pt1', Poly1),
    make_polygon([point(2.5, -3.5)], 'Pt2', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    length(Vertices, 1),
    contains_point(Result, 0, 0).

test_algo_a_06_empty_first_polygon :-
    make_polygon([], 'Empty', Poly1),
    make_polygon([point(0, 0), point(1, 1)], 'Line', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    Vertices == [].

test_algo_a_07_empty_second_polygon :-
    make_polygon([point(0, 0), point(1, 1)], 'Line', Poly1),
    make_polygon([], 'Empty', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    Vertices == [].

test_algo_a_08_null_arguments :-
    make_polygon([point(0, 0)], 'Pt', Poly),
    calculate_clean_minkowski_sum(none, Poly, none),
    calculate_clean_minkowski_sum(Poly, none, none),
    calculate_clean_minkowski_sum(none, none, none).

test_algo_a_09_flat_polygon :-
    make_polygon([point(0, 0), point(2, 0)], 'Line1', Poly1),
    make_polygon([point(0, 0), point(3, 0)], 'Line2', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    length(Vertices, 2),
    contains_point(Result, 0, 0),
    contains_point(Result, 5, 0).

test_algo_a_10_stress_test :-
    length(CirclePoints, 500),
    numlist(0, 499, Indices),
    maplist(circle_point(500), Indices, CirclePoints),
    make_polygon(CirclePoints, 'Circle1', Poly1),
    make_polygon(CirclePoints, 'Circle2', Poly2),
    calculate_clean_minkowski_sum(Poly1, Poly2, Result),
    Result = polygon(Vertices, _, _, _),
    length(Vertices, Len),
    Len > 0.

circle_point(Size, I, point(X, Y)) :-
    Angle is 2.0 * pi * I / Size,
    X is cos(Angle),
    Y is sin(Angle).

test_algo_b_01_tunneling_collision :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(5, 0), point(6, 0), point(6, 1), point(5, 1)], 'Obstacle', Obstacle),
    check_dynamic_collision(Obstacle, Robot, point(10, 0)).

test_algo_b_02_clear_miss :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(0, 5), point(1, 5), point(1, 6), point(0, 6)], 'Obstacle', Obstacle),
    \+ check_dynamic_collision(Obstacle, Robot, point(10, 0)).

test_algo_b_03_static_overlap :-
    make_polygon([point(0, 0), point(2, 0), point(2, 2), point(0, 2)], 'Robot', Robot),
    make_polygon([point(1, 1), point(3, 1), point(3, 3), point(1, 3)], 'Obstacle', Obstacle),
    check_dynamic_collision(Obstacle, Robot, point(0, 0)).

test_algo_b_04_static_miss :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(10, 10), point(11, 10), point(11, 11), point(10, 11)], 'Obstacle', Obstacle),
    \+ check_dynamic_collision(Obstacle, Robot, point(0, 0)).

test_algo_b_05_moving_away :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(-5, 0), point(-4, 0), point(-4, 1), point(-5, 1)], 'Obstacle', Obstacle),
    \+ check_dynamic_collision(Obstacle, Robot, point(10, 0)).

test_algo_b_06_diagonal_tunneling :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(5, 5), point(7, 5), point(7, 7), point(5, 7)], 'Obstacle', Obstacle),
    check_dynamic_collision(Obstacle, Robot, point(10, 10)).

test_algo_b_07_edge_grazing :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Robot', Robot),
    make_polygon([point(0, 1), point(1, 1), point(1, 2), point(0, 2)], 'Obstacle', Obstacle),
    check_dynamic_collision(Obstacle, Robot, point(10, 0)).

test_algo_b_08_negative_velocity :-
    make_polygon([point(10, 10), point(11, 10), point(11, 11), point(10, 11)], 'Robot', Robot),
    make_polygon([point(4, 4), point(6, 4), point(6, 6), point(4, 6)], 'Obstacle', Obstacle),
    check_dynamic_collision(Obstacle, Robot, point(-10, -10)).

test_algo_b_09_empty_polygons :-
    make_polygon([], 'Empty', EmptyPoly),
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Obstacle', Obstacle),
    \+ check_dynamic_collision(Obstacle, EmptyPoly, point(5, 5)),
    \+ check_dynamic_collision(EmptyPoly, Obstacle, point(5, 5)).

test_algo_b_10_null_arguments :-
    make_polygon([point(0, 0), point(1, 0), point(1, 1), point(0, 1)], 'Obstacle', Obstacle),
    \+ check_dynamic_collision(none, Obstacle, point(5, 5)),
    \+ check_dynamic_collision(Obstacle, none, point(5, 5)),
    \+ check_dynamic_collision(none, none, point(5, 5)).

main :-
    Tests = [
      'test_algo_a_01_basic_squares'-test_algo_a_01_basic_squares,
      'test_algo_a_02_point_and_polygon'-test_algo_a_02_point_and_polygon,
      'test_algo_a_03_collinear_simplification'-test_algo_a_03_collinear_simplification,
      'test_algo_a_04_negative_coordinates'-test_algo_a_04_negative_coordinates,
      'test_algo_a_05_single_points'-test_algo_a_05_single_points,
      'test_algo_a_06_empty_first_polygon'-test_algo_a_06_empty_first_polygon,
      'test_algo_a_07_empty_second_polygon'-test_algo_a_07_empty_second_polygon,
      'test_algo_a_08_null_arguments'-test_algo_a_08_null_arguments,
      'test_algo_a_09_flat_polygon'-test_algo_a_09_flat_polygon,
      'test_algo_a_10_stress_test'-test_algo_a_10_stress_test,
      'test_algo_b_01_tunneling_collision'-test_algo_b_01_tunneling_collision,
      'test_algo_b_02_clear_miss'-test_algo_b_02_clear_miss,
      'test_algo_b_03_static_overlap'-test_algo_b_03_static_overlap,
      'test_algo_b_04_static_miss'-test_algo_b_04_static_miss,
      'test_algo_b_05_moving_away'-test_algo_b_05_moving_away,
      'test_algo_b_06_diagonal_tunneling'-test_algo_b_06_diagonal_tunneling,
      'test_algo_b_07_edge_grazing'-test_algo_b_07_edge_grazing,
      'test_algo_b_08_negative_velocity'-test_algo_b_08_negative_velocity,
      'test_algo_b_09_empty_polygons'-test_algo_b_09_empty_polygons,
      'test_algo_b_10_null_arguments'-test_algo_b_10_null_arguments
    ],
        length(Tests, TotalTests),
        run_all_tests(Tests, 0, 0, [], FailedTestsReversed, PassedCount, FailedCount),
        reverse(FailedTestsReversed, FailedTests),
    nl,
    writeln('=== BENCHMARK RESULTS ==='),
        format('Completed ~w tests.~n', [TotalTests]),
    format('Passed: ~w~n', [PassedCount]),
    format('Failed: ~w~n', [FailedCount]),
    (   FailedCount =:= 0
    ->  writeln('All tests passed!'),
        halt(0)
    ;   writeln('Tests that failed:'),
        print_failed_tests(FailedTests),
        halt(1)
    ).

run_all_tests([], Passed, Failed, FailedAcc, FailedAcc, Passed, Failed).
run_all_tests([Name-Goal | Rest], Passed0, Failed0, FailedAcc0, FailedAcc, Passed, Failed) :-
    run_test(Name, Goal, Passed0, Passed1, FailedAcc0, FailedAcc1),
    (   Passed1 > Passed0
    ->  Failed1 is Failed0
    ;   Failed1 is Failed0 + 1
    ),
    run_all_tests(Rest, Passed1, Failed1, FailedAcc1, FailedAcc, Passed, Failed).

print_failed_tests([]).
print_failed_tests([Name | Rest]) :-
    format(' - ~w~n', [Name]),
    print_failed_tests(Rest).
