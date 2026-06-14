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

calculate_clean_minkowski_sum(_, _, _) :-
    throw(error(existence_error(procedure, calculate_clean_minkowski_sum/3), _)).

check_dynamic_collision(_, _, _) :-
    throw(error(existence_error(procedure, check_dynamic_collision/3), _)).

create_polygon(_, _, _) :-
    throw(error(existence_error(procedure, create_polygon/3), _)).

free_polygon(_).

create_layer(_, _) :-
    throw(error(existence_error(procedure, create_layer/2), _)).

free_layer(_).
