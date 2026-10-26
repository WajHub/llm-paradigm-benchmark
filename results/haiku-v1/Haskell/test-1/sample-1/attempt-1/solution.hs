module SpatialLogic
  ( Point (..)
  , Polygon (..)
  , SpatialLayer (..)
  , calculateCleanMinkowskiSum
  , checkDynamicCollision
  ) where

import Data.Function (on)
import Data.List (groupBy, sortBy)
import Data.Ord (comparing)

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

-- | Z-component of the cross product (a - o) x (b - o).
-- Positive when o -> a -> b turns counter-clockwise.
cross :: Point -> Point -> Point -> Double
cross o a b =
  (pointX a - pointX o) * (pointY b - pointY o)
    - (pointY a - pointY o) * (pointX b - pointX o)

sortKey :: Point -> (Double, Double)
sortKey p = (pointX p, pointY p)

-- | Strict convex hull (Andrew's monotone chain).
-- Returns vertices in counter-clockwise order with collinear points removed.
-- Degenerate inputs yield fewer than three vertices (0, 1 or 2 points).
convexHull :: [Point] -> [Point]
convexHull pts
  | length sorted < 3 = sorted
  | otherwise = lowerH ++ upperH
  where
    sorted = map head . groupBy ((==) `on` sortKey) . sortBy (comparing sortKey) $ pts
    lowerH = init (reverse (foldl step [] sorted))
    upperH = init (reverse (foldl step [] (reverse sorted)))
    step (top : below : rest) p
      | cross below top p <= 0 = step (below : rest) p
    step acc p = p : acc

-- | Point cloud of all pairwise vertex sums (Minkowski sum before hulling).
minkowskiCloud :: [Point] -> [Point] -> [Point]
minkowskiCloud as bs =
  [ Point (pointX p + pointX q) (pointY p + pointY q) | p <- as, q <- bs ]

negatePoint :: Point -> Point
negatePoint (Point x y) = Point (negate x) (negate y)

-- | Directed edges of a polygon (a single point is treated as a degenerate edge).
edges :: [Point] -> [(Point, Point)]
edges [] = []
edges [p] = [(p, p)]
edges ps@(p : _) = zip ps (drop 1 ps ++ [p])

-- | Inclusive point-in-convex-polygon test for a CCW polygon with >= 3 vertices.
containsPoint :: [Point] -> Point -> Bool
containsPoint poly p
  | length poly < 3 = False
  | otherwise = all (\(a, b) -> cross a b p >= 0) (edges poly)

-- | Whether c lies within the bounding box of segment a-b (assumes collinearity).
onSegment :: Point -> Point -> Point -> Bool
onSegment a b c =
  between (pointX a) (pointX b) (pointX c) && between (pointY a) (pointY b) (pointY c)
  where
    between u v w = min u v <= w && w <= max u v

-- | Inclusive segment-segment intersection (touching counts).
segmentsIntersect :: (Point, Point) -> (Point, Point) -> Bool
segmentsIntersect (p1, p2) (q1, q2) = properCross || touching
  where
    d1 = signum (cross q1 q2 p1)
    d2 = signum (cross q1 q2 p2)
    d3 = signum (cross p1 p2 q1)
    d4 = signum (cross p1 p2 q2)
    properCross = d1 * d2 < 0 && d3 * d4 < 0
    touching =
      or [ d1 == 0 && onSegment q1 q2 p1
         , d2 == 0 && onSegment q1 q2 p2
         , d3 == 0 && onSegment p1 p2 q1
         , d4 == 0 && onSegment p1 p2 q2
         ]

-- | Minkowski sum of two convex polygons, reduced to its strict convex hull.
-- Returns Nothing only if either polygon is absent; degenerate results
-- (empty, single point, or segment) are represented by the hull vertices found.
calculateCleanMinkowskiSum :: Maybe Polygon -> Maybe Polygon -> Maybe Polygon
calculateCleanMinkowskiSum (Just a) (Just b) = Just Polygon
  { polygonVertices = hull
  , polygonNumVertices = length hull
  , polygonIsConvex = True
  , polygonZoneName = polygonZoneName a ++ "+" ++ polygonZoneName b
  }
  where
    hull = convexHull (minkowskiCloud (polygonVertices a) (polygonVertices b))
calculateCleanMinkowskiSum _ _ = Nothing

-- | Sweeps the robot along the segment from the origin to the velocity vector
-- and reports whether it touches the stationary obstacle. The robot's
-- configuration-space obstacle (obstacle minus robot, as a Minkowski sum)
-- is intersected with the motion segment.
checkDynamicCollision :: Maybe Polygon -> Maybe Polygon -> Point -> Bool
checkDynamicCollision (Just obstacle) (Just robot) (Point vx vy) =
  case cfg of
    [] -> False
    _  -> containsPoint cfg origin
          || containsPoint cfg target
          || any (segmentsIntersect motion) (edges cfg)
  where
    cfg = convexHull
            (minkowskiCloud (polygonVertices obstacle)
                            (map negatePoint (polygonVertices robot)))
    origin = Point 0 0
    target = Point vx vy
    motion = (origin, target)
checkDynamicCollision _ _ _ = False
