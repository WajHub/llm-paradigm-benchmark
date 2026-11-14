module SequenceAlignment
  ( AlignResult (..)
  , alignmentScore
  , alignmentAlign
  ) where

import Data.Array

-- One optimal global alignment: the two gapped rows ('-' = gap) and its score.
data AlignResult = AlignResult
  { arScore    :: Int
  , arAlignedA :: String
  , arAlignedB :: String
  } deriving (Eq, Show)

-- Gotoh DP states: M = ends with a pair column, X = ends with a gap in b
-- (consumes a character of a), Y = ends with a gap in a (consumes b).
data St = SM | SX | SY deriving (Eq, Show)

data Tabs = Tabs
  { tM :: Array (Int, Int) Int
  , tX :: Array (Int, Int) Int
  , tY :: Array (Int, Int) Int
  }

negInf :: Int
negInf = -(10 ^ (15 :: Int))

-- Value of the M table, with the start cell (0,0) treated as a score-0 "end".
endMAt :: Tabs -> Int -> Int -> Int
endMAt t i j
  | i == 0 && j == 0 = 0
  | otherwise        = tM t ! (i, j)

-- Best value over all states ending at (i,j).
bestAt :: Tabs -> Int -> Int -> Int
bestAt t i j = maximum [endMAt t i j, tX t ! (i, j), tY t ! (i, j)]

buildTabs :: Array Int Char -> Array Int Char -> Int -> Int -> Int -> Int -> Tabs
buildTabs ca cb ma mp go ge = t
  where
    n = snd (bounds ca)
    m = snd (bounds cb)
    bnds = ((0, 0), (n, m))
    t = Tabs mT xT yT
    mT = array bnds [((i, j), mv i j) | i <- [0 .. n], j <- [0 .. m]]
    xT = array bnds [((i, j), xv i j) | i <- [0 .. n], j <- [0 .. m]]
    yT = array bnds [((i, j), yv i j) | i <- [0 .. n], j <- [0 .. m]]

    mv i j
      | i == 0 || j == 0 = negInf
      | otherwise =
          bestAt t (i - 1) (j - 1) + (if ca ! i == cb ! j then ma else negInf') 
      where negInf' = -mp

    xv i j
      | i == 0 = negInf
      | otherwise = maximum
          [ endMAt t (i - 1) j - go - ge
          , tX t ! (i - 1, j) - ge
          , tY t ! (i - 1, j) - go - ge
          ]

    yv i j
      | j == 0 = negInf
      | otherwise = maximum
          [ endMAt t i (j - 1) - go - ge
          , tY t ! (i, j - 1) - ge
          , tX t ! (i, j - 1) - go - ge
          ]

-- alignmentScore a b matchScore mismatchPenalty gapOpen gapExtend
alignmentScore :: String -> String -> Int -> Int -> Int -> Int -> Int
alignmentScore a b ma mp go ge = bestAt t n m
  where
    n = length a
    m = length b
    ca = listArray (1, n) a
    cb = listArray (1, m) b
    t = buildTabs ca cb ma mp go ge

-- alignmentAlign a b matchScore mismatchPenalty gapOpen gapExtend
alignmentAlign :: String -> String -> Int -> Int -> Int -> Int -> AlignResult
alignmentAlign a b ma mp go ge = AlignResult score rowA rowB
  where
    n = length a
    m = length b
    ca = listArray (1, n) a
    cb = listArray (1, m) b
    t = buildTabs ca cb ma mp go ge
    score = bestAt t n m

    initState
      | endMAt t n m == score = SM
      | tX t ! (n, m) == score = SX
      | otherwise = SY

    (rowA, rowB) = walk initState n m [] []

    walk :: St -> Int -> Int -> String -> String -> (String, String)
    walk st i j accA accB
      | i == 0 && j == 0 = (accA, accB)
      | otherwise = case st of
          SM ->
            let v = bestAt t (i - 1) (j - 1)
                pst | endMAt t (i - 1) (j - 1) == v = SM
                    | tX t ! (i - 1, j - 1) == v = SX
                    | otherwise = SY
            in walk pst (i - 1) (j - 1) (ca ! i : accA) (cb ! j : accB)
          SX ->
            let cur = tX t ! (i, j)
                pst | cur == tX t ! (i - 1, j) - ge = SX
                    | cur == endMAt t (i - 1) j - go - ge = SM
                    | otherwise = SY
            in walk pst (i - 1) j (ca ! i : accA) ('-' : accB)
          SY ->
            let cur = tY t ! (i, j)
                pst | cur == tY t ! (i, j - 1) - ge = SY
                    | cur == endMAt t i (j - 1) - go - ge = SM
                    | otherwise = SX
            in walk pst i (j - 1) ('-' : accA) (cb ! j : accB)
