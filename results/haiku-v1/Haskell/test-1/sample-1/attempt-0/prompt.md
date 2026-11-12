You are a Haskell programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `calculateCleanMinkowskiSum`: Calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points, ordered counter-clockwise, with collinear boundary points removed.
- Implement `checkDynamicCollision`: Determine if a moving robot polygon intersects with a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum configuration-space approach to prevent tunneling. Return `True` if a collision occurs, `False` otherwise.
- Model inputs idiomatically with immutable records and `Maybe` for absent polygons.

General Requirements:
- Use idiomatic, pure Haskell.
- Prefer immutable data, algebraic data types, and total functions where practical.
- Model absence with `Maybe` instead of null pointers.
- Return ONLY raw Haskell code (no Markdown tags, no ```haskell blocks, no side text). Your code will be directly saved to a .hs file and compiled.
- Do not provide test runner code.

module SpatialLogic
  ( Point (..)
  , Polygon (..)
  , SpatialLayer (..)
  , calculateCleanMinkowskiSum
  , checkDynamicCollision
  ) where

data Point = Point
  { pointX :: Double
  , pointY :: Double
  } deriving (Eq, Show)

data Polygon = Polygon
  { polygonVertices :: [Point]
  , polygonNumVertices :: Int
  , polygonIsConvex :: Bool
  , polygonZoneName :: String
  } deriving (Eq, Show)

data SpatialLayer = SpatialLayer
  { layerPolygons :: [Polygon]
  , layerPolygonCount :: Int
  , layerName :: String
  } deriving (Eq, Show)

calculateCleanMinkowskiSum :: Maybe Polygon -> Maybe Polygon -> Maybe Polygon
calculateCleanMinkowskiSum _ _ = error "SpatialLogic.calculateCleanMinkowskiSum not implemented"

checkDynamicCollision :: Maybe Polygon -> Maybe Polygon -> Point -> Bool
checkDynamicCollision _ _ _ = error "SpatialLogic.checkDynamicCollision not implemented"