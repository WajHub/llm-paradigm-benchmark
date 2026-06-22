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
