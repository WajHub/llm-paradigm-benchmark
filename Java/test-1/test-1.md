# Test 1

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `calculateCleanMinkowskiSum`: calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The returned polygon must contain strictly extreme points only, with collinear edge points removed, ordered counter-clockwise.
- Implement `checkDynamicCollision`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum configuration-space approach to prevent tunneling.
- Implement `createPolygon` and `createLayer`: allocate the required objects and safely copy the provided names into the corresponding fields.
- Use object-oriented Java and model the domain with classes.
- Keep the contract in `SpatialLogic.java`, the concrete solution will live in `SpatialLogicImpl.java`.
- Return only raw Java code.
```