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

import qualified Data.Map.Strict as M
import qualified Data.Set as S

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

infinity :: Double
infinity = 1 / 0

createGraph :: Int -> Graph
createGraph n = Graph (replicate n' []) n'
  where
    n' = max 0 n

addEdge :: Graph -> Int -> Int -> Double -> Graph
addEdge g u v w
  | u < 0 || u >= n = g
  | v < 0 || v >= n = g
  | otherwise = g { graphAdjacency = adj' }
  where
    n = graphNumVertices g
    adj = graphAdjacency g
    (before, rest) = splitAt u adj
    adj' = case rest of
      (lst : after) -> before ++ (lst ++ [Edge v w]) : after
      []            -> adj

dijkstra :: Maybe Graph -> Int -> Maybe PathResult
dijkstra Nothing _ = Nothing
dijkstra (Just g) src
  | src < 0 || src >= n = Nothing
  | otherwise = Just PathResult
      { prDistances    = [M.findWithDefault infinity i dist | i <- [0 .. n - 1]]
      , prPredecessors = [M.findWithDefault (-1) i preds | i <- [0 .. n - 1]]
      , prSource       = src
      }
  where
    n = graphNumVertices g
    adjM = M.fromList (zip [0 ..] (graphAdjacency g))
    initDist = M.singleton src 0
    initPreds = M.empty :: M.Map Int Int
    (dist, preds) = go (S.singleton (0, src)) initDist initPreds

    go :: S.Set (Double, Int) -> M.Map Int Double -> M.Map Int Int
       -> (M.Map Int Double, M.Map Int Int)
    go pq ds ps = case S.minView pq of
      Nothing -> (ds, ps)
      Just ((d, u), pq')
        | d > M.findWithDefault infinity u ds -> go pq' ds ps
        | otherwise ->
            let relax (q, dm, pm) (Edge v w) =
                  let nd = d + w
                  in if nd < M.findWithDefault infinity v dm
                       then (S.insert (nd, v) q, M.insert v nd dm, M.insert v u pm)
                       else (q, dm, pm)
                (pq'', ds', ps') =
                  foldl relax (pq', ds, ps) (M.findWithDefault [] u adjM)
            in go pq'' ds' ps'

getShortestDistance :: Maybe PathResult -> Int -> Double
getShortestDistance Nothing _ = infinity
getShortestDistance (Just pr) t
  | t < 0 = infinity
  | otherwise = case drop t (prDistances pr) of
      (x : _) -> x
      []      -> infinity

reconstructPath :: Maybe PathResult -> Int -> Maybe [Int]
reconstructPath Nothing _ = Nothing
reconstructPath (Just pr) t
  | t < 0 || t >= length ds = Nothing
  | isInfinite (ds !! t) = Nothing
  | otherwise = go (length ds) t []
  where
    ds = prDistances pr
    ps = prPredecessors pr
    src = prSource pr

    go :: Int -> Int -> [Int] -> Maybe [Int]
    go fuel v acc
      | v == src = Just (v : acc)
      | fuel <= 0 = Nothing
      | otherwise = case drop v ps of
          (p : _) | p >= 0 -> go (fuel - 1) p (v : acc)
          _                -> Nothing
