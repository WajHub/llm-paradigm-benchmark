# Test 1

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `calculate_clean_minkowski_sum`: Calculate the Minkowski sum of two convex polygons (poly1 and poly2), and return a new polygon representing ONLY the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points (collinear points on the edges must be removed) and ordered counter-clockwise.
- Implement `check_dynamic_collision`: Determine if a moving robot polygon intersects with a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum Configuration Space approach to prevent tunneling (continuous collision detection). Return true if a collision occurs, false otherwise.
- Implement `create_polygon` & `create_layer`: Properly allocate memory for the structures and safely copy the provided strings into zone_name and layer_name.
```