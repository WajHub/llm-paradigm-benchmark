You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

- Implement `calculate_clean_minkowski_sum/3`: calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points, ordered counter-clockwise, with collinear boundary points removed.
- Implement `check_dynamic_collision/3`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski-sum configuration-space approach to prevent tunneling. The predicate should succeed when a collision occurs and fail otherwise.
- Represent polygons and layers using idiomatic Prolog terms and keep the interface module-exported.

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

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