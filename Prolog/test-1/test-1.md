# Test 1

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```text
- Implement `calculate_clean_minkowski_sum/3`: calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points, ordered counter-clockwise, with collinear boundary points removed.
- Implement `check_dynamic_collision/3`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski-sum configuration-space approach to prevent tunneling. The predicate should succeed when a collision occurs and fail otherwise.
- Represent polygons and layers using idiomatic Prolog terms and keep the interface module-exported.
```
