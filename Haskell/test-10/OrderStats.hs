module OrderStats
  ( SelectResult (..)
  , Source (..)
  , medianOfMedians
  , selectKth
  , medianTwoSorted
  ) where

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

medianOfMedians :: [Int] -> Maybe Int
medianOfMedians _ = error "OrderStats.medianOfMedians not implemented"

-- selectKth xs k  (k is 0-based)
selectKth :: [Int] -> Int -> Maybe SelectResult
selectKth _ _ = error "OrderStats.selectKth not implemented"

medianTwoSorted :: Monad m => Source m -> Source m -> m (Maybe Double)
medianTwoSorted _ _ = error "OrderStats.medianTwoSorted not implemented"
