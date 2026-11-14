module OrderStats
  ( SelectResult (..)
  , Source (..)
  , medianOfMedians
  , selectKth
  , medianTwoSorted
  ) where

import Data.List (sort)

-- The k-th smallest value and the BFPRT pivots chosen at each top-level step.
data SelectResult = SelectResult
  { selValue  :: Int
  , selPivots :: [Int]
  } deriving (Eq, Show)

-- A read-only sorted (non-decreasing) sequence that can only be read through
-- the monadic probe srcGet (0-based index, 0 <= index < srcLength).
-- Reading the length is free; every srcGet call is counted.
data Source m = Source
  { srcLength :: Int
  , srcGet    :: Int -> m Int
  }

-- Lower median of a non-empty list: index (length - 1) `div` 2 after sorting.
lowerMedian :: [Int] -> Int
lowerMedian g = sort g !! ((length g - 1) `div` 2)

-- Split into consecutive chunks of at most 5 elements (order preserved).
chunks5 :: [Int] -> [[Int]]
chunks5 [] = []
chunks5 ys = let (a, b) = splitAt 5 ys in a : chunks5 b

medianOfMedians :: [Int] -> Maybe Int
medianOfMedians [] = Nothing
medianOfMedians xs = Just (lowerMedian (map lowerMedian (chunks5 xs)))

-- selectKth xs k  (k is 0-based)
selectKth :: [Int] -> Int -> Maybe SelectResult
selectKth xs k
  | k < 0 || k >= length xs = Nothing
  | otherwise = go xs k []
  where
    go cur i acc
      | length cur <= 5 = Just (SelectResult (sort cur !! i) (reverse acc))
      | otherwise = case medianOfMedians cur of
          Nothing -> Nothing
          Just p ->
            let l     = filter (< p) cur
                g     = filter (> p) cur
                nl    = length l
                e     = length cur - nl - length g
                acc'  = p : acc
            in if i < nl
                 then go l i acc'
                 else if i < nl + e
                   then Just (SelectResult p (reverse acc'))
                   else go g (i - nl - e) acc'

-- Median of two sorted sources via binary search for a partition.
-- The shorter source is searched; each probe step reads at most 2 values.
medianTwoSorted :: Monad m => Source m -> Source m -> m (Maybe Double)
medianTwoSorted sa sb
  | total == 0 = return Nothing
  | otherwise = do
      i <- search lo' hi'
      let j = half - i
      leftVals <- sequence $
        [ srcGet a (i - 1) | i > 0 ] ++ [ srcGet b (j - 1) | j > 0 ]
      let leftMax = maximum leftVals
      if odd total
        then return (Just (fromIntegral leftMax))
        else do
          rightVals <- sequence $
            [ srcGet a i | i < m ] ++ [ srcGet b j | j < n ]
          let rightMin = minimum rightVals
          return (Just ((fromIntegral leftMax + fromIntegral rightMin) / 2))
  where
    -- a is the shorter source, b the longer one
    (a, b) = if srcLength sa <= srcLength sb then (sa, sb) else (sb, sa)
    m = srcLength a
    n = srcLength b
    total = m + n
    odd' = odd total
    half = (total + 1) `div` 2
    lo' = max 0 (half - n)
    hi' = min m half

    -- Predicate: taking i elements from a on the left is acceptable,
    -- i.e. a[i] >= b[j-1] (monotone in i).
    ok i = do
      let j = half - i
      if i == m || j == 0
        then return True
        else do
          bv <- srcGet b (j - 1)
          av <- srcGet a i
          return (av >= bv)

    -- Smallest i in [l, h] satisfying ok; h always satisfies it.
    search l h
      | l >= h = return l
      | otherwise = do
          let mid = l + (h - l) `div` 2
          good <- ok mid
          if good then search l mid else search (mid + 1) h

    _unused = odd'
