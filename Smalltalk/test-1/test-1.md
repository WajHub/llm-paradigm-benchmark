# Test 1

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `calculateCleanMinkowskiSum: poly1 with: poly2`: calculate the Minkowski sum of two convex polygons and return a new Polygon representing only the convex hull of the resulting point cloud. The returned polygon must contain strictly extreme points only, with collinear edge points removed, ordered counter-clockwise.
- Implement `checkDynamicCollision: obstacle robot: robot velocity: velocity`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector (a Point). Use the Minkowski sum configuration-space approach to prevent tunneling.
- Implement `createPolygon: numVertices name: aName` and `createLayer: aName`: allocate the required objects (Polygon, SpatialLayer) and safely copy the provided names into the corresponding fields.
- The built-in Point class (with `x` and `y` accessors, created via `Point x: ... y: ...`) is used for 2D coordinates and velocity vectors.
- Handle nil arguments gracefully: `calculateCleanMinkowskiSum:with:` returns nil when either argument is nil; `checkDynamicCollision:robot:velocity:` returns false when either polygon is nil or has nil/empty vertices.
- Use idiomatic GNU Smalltalk and object-oriented design.
- Keep the contract in `SpatialLogic.st`, the concrete solution will live in `SpatialLogicImpl.st`.
- Return only raw Smalltalk code.
```
