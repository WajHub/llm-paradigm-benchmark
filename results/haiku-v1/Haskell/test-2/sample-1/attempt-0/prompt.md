You are a Haskell programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `createGraph`: Create a directed weighted graph with the given number of vertices (0-indexed). Return a Graph with empty adjacency lists.
- Implement `addEdge`: Return a new Graph with the directed edge added. Support multiple edges between same vertices.
- Implement `dijkstra`: Run Dijkstra's algorithm. Takes Maybe Graph and source Int. Return Nothing if graph is Nothing or source out of bounds. Unreachable vertices must have distance Infinity (1/0).
- Implement `getShortestDistance`: Takes Maybe PathResult and target. Return Infinity if Nothing or out of bounds.
- Implement `reconstructPath`: Return Maybe [Int] — Just path or Nothing if unreachable/invalid.
- Use a priority queue or efficient data structure.
- Use idiomatic Haskell (immutable data, pure functions where possible).

General Requirements:
- Use idiomatic, pure Haskell.
- Prefer immutable data, algebraic data types, and total functions where practical.
- Model absence with `Maybe` instead of null pointers.
- Return ONLY raw Haskell code (no Markdown tags, no ```haskell blocks, no side text). Your code will be directly saved to a .hs file and compiled.
- Do not provide test runner code.

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