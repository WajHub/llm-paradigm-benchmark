module SequenceAlignment
  ( AlignResult (..)
  , alignmentScore
  , alignmentAlign
  ) where

-- One optimal global alignment: the two gapped rows ('-' = gap) and its score.
data AlignResult = AlignResult
  { arScore    :: Int
  , arAlignedA :: String
  , arAlignedB :: String
  } deriving (Eq, Show)

-- alignmentScore a b matchScore mismatchPenalty gapOpen gapExtend
alignmentScore :: String -> String -> Int -> Int -> Int -> Int -> Int
alignmentScore _ _ _ _ _ _ = error "SequenceAlignment.alignmentScore not implemented"

-- alignmentAlign a b matchScore mismatchPenalty gapOpen gapExtend
alignmentAlign :: String -> String -> Int -> Int -> Int -> Int -> AlignResult
alignmentAlign _ _ _ _ _ _ = error "SequenceAlignment.alignmentAlign not implemented"
