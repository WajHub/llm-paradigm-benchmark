module ShortestPath
  ( Edge (..)
  , Graph (..)
  , PathResult (..)
  , createGraph
  , addEdge
  , dijkstra
  , getShortestDistance
  , reconstructPath
  ) where

data Edge = Edge
  { edgeTo     :: Int
  , edgeWeight :: Double
  } deriving (Eq, Show)

data Graph = Graph
  { graphAdjacency   :: [[Edge]]
  , graphNumVertices  :: Int
  } deriving (Eq, Show)

data PathResult = PathResult
  { prDistances    :: [Double]
  , prPredecessors :: [Int]
  , prSource       :: Int
  } deriving (Eq, Show)

createGraph :: Int -> Graph
createGraph _ = error "ShortestPath.createGraph not implemented"

addEdge :: Graph -> Int -> Int -> Double -> Graph
addEdge _ _ _ _ = error "ShortestPath.addEdge not implemented"

dijkstra :: Maybe Graph -> Int -> Maybe PathResult
dijkstra _ _ = error "ShortestPath.dijkstra not implemented"

getShortestDistance :: Maybe PathResult -> Int -> Double
getShortestDistance _ _ = error "ShortestPath.getShortestDistance not implemented"

reconstructPath :: Maybe PathResult -> Int -> Maybe [Int]
reconstructPath _ _ = error "ShortestPath.reconstructPath not implemented"
