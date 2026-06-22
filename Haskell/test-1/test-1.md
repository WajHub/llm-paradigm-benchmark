# Test 1

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```text
- Implement `calculateCleanMinkowskiSum`: Calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points, ordered counter-clockwise, with collinear boundary points removed.
- Implement `checkDynamicCollision`: Determine if a moving robot polygon intersects with a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum configuration-space approach to prevent tunneling. Return `True` if a collision occurs, `False` otherwise.
- Model inputs idiomatically with immutable records and `Maybe` for absent polygons.
```
