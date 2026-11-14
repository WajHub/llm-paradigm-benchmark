module TspApprox
  ( TourResult (..)
  , mstWeight
  , doubleTree
  , matchingWeight
  , christofides
  ) where

import Data.Array
import Data.Bits
import Data.List (delete, nub, sort)

-- A closed tour: vertex indices in visiting order (starting with 0) and its cost.
data TourResult = TourResult
  { tourOrder :: [Int]
  , tourCost  :: Int
  } deriving (Eq, Show)

-- Manhattan distance between two points.
dist :: (Int, Int) -> (Int, Int) -> Int
dist (x1, y1) (x2, y2) = abs (x1 - x2) + abs (y1 - y2)

-- Build an indexed array of points (vertex i = i-th point).
mkArr :: [(Int, Int)] -> Array Int (Int, Int)
mkArr ps = listArray (0, length ps - 1) ps

-- Distance between vertices i and j.
dAt :: Array Int (Int, Int) -> Int -> Int -> Int
dAt pts i j = dist (pts ! i) (pts ! j)

-- MST edges as (parent, child) pairs, in the order they are added by Prim's algorithm.
mstEdgesA :: Array Int (Int, Int) -> [(Int, Int)]
mstEdgesA pts = go [0] [1 .. n - 1]
  where
    n = rangeSize (bounds pts)
    d = dAt pts
    go :: [Int] -> [Int] -> [(Int, Int)]
    go _ [] = []
    go tree rest =
      let (k, v) = minimum [ (minimum [d u w | u <- tree], w) | w <- rest ]
          p = minimum [ u | u <- tree, d u v == k ]
      in (p, v) : go (v : tree) (delete v rest)

-- Total cost of a closed tour given as a vertex order.
tourCostA :: Array Int (Int, Int) -> [Int] -> Int
tourCostA pts order =
  sum [ dAt pts a b | (a, b) <- zip order (drop 1 order ++ take 1 order) ]

-- Children of v in the tree given by (parent, child) edges, ascending.
childrenOf :: [(Int, Int)] -> Int -> [Int]
childrenOf edges v = sort [ w | (p, w) <- edges, p == v ]

-- Vertices of odd degree in the edge multigraph on n vertices.
oddVertices :: Int -> [(Int, Int)] -> [Int]
oddVertices n edges =
  [ v | v <- [0 .. n - 1]
      , odd (length [ () | (a, b) <- edges, a == v || b == v ]) ]

mstWeight :: [(Int, Int)] -> Int
mstWeight ps = sum [ dAt pts p v | (p, v) <- mstEdgesA pts ]
  where
    pts = mkArr ps

doubleTree :: [(Int, Int)] -> Maybe TourResult
doubleTree [] = Nothing
doubleTree ps = Just (TourResult order (tourCostA pts order))
  where
    pts = mkArr ps
    edges = mstEdgesA pts
    dfs :: Int -> [Int]
    dfs v = v : concatMap dfs (childrenOf edges v)
    order = dfs 0

-- Minimum-weight perfect matching of the given vertices (exact bitmask DP).
-- Returns the total weight and the matched pairs (in vertex indices).
minMatching :: Array Int (Int, Int) -> [Int] -> (Int, [(Int, Int)])
minMatching pts os = table ! full
  where
    k = length os
    ov = listArray (0, k - 1) os :: Array Int Int
    w i j = dAt pts (ov ! i) (ov ! j)
    full = bit k - 1
    inf = maxBound `div` 2 :: Int
    table :: Array Int (Int, [(Int, Int)])
    table = listArray (0, full) [ f m | m <- [0 .. full] ]
    f :: Int -> (Int, [(Int, Int)])
    f 0 = (0, [])
    f m
      | odd (popCount m) = (inf, [])
      | otherwise = minimum cands
      where
        i = countTrailingZeros m
        cands =
          [ (c + w i j, (ov ! i, ov ! j) : ps)
          | j <- [i + 1 .. k - 1]
          , testBit m j
          , let (c, ps) = table ! (m .&. complement (bit i .|. bit j))
          ]

matchingWeight :: [(Int, Int)] -> Int
matchingWeight ps = fst (minMatching pts (oddVertices n mst))
  where
    n = length ps
    pts = mkArr ps
    mst = mstEdgesA pts

-- Hierholzer's algorithm on an edge multigraph (edge ids = list positions).
eulerCircuit :: [(Int, Int)] -> [Int]
eulerCircuit edges = go [0] [] []
  where
    indexed = zip [0 ..] edges
    adj :: Int -> [(Int, Int)]
    adj v = [ (u, e)
            | (e, (a, b)) <- indexed
            , a == v || b == v
            , let u = if a == v then b else a
            ]
    go :: [Int] -> [Int] -> [Int] -> [Int]
    go [] _ circ = circ
    go (v : st) used circ =
      case [ (u, e) | (u, e) <- adj v, e `notElem` used ] of
        ((u, e) : _) -> go (u : v : st) (e : used) circ
        []           -> go st used (v : circ)

christofides :: [(Int, Int)] -> Maybe TourResult
christofides [] = Nothing
christofides [_] = Just (TourResult [0] 0)
christofides ps = Just (TourResult tour (tourCostA pts tour))
  where
    n = length ps
    pts = mkArr ps
    mst = mstEdgesA pts
    os = oddVertices n mst
    (_, match) = minMatching pts os
    circuit = eulerCircuit (mst ++ match)
    tour = nub circuit
