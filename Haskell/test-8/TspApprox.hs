module TspApprox
  ( TourResult (..)
  , mstWeight
  , doubleTree
  , matchingWeight
  , christofides
  ) where

-- A closed tour: vertex indices in visiting order (starting with 0) and its cost.
data TourResult = TourResult
  { tourOrder :: [Int]
  , tourCost  :: Int
  } deriving (Eq, Show)

mstWeight :: [(Int, Int)] -> Int
mstWeight _ = error "TspApprox.mstWeight not implemented"

doubleTree :: [(Int, Int)] -> Maybe TourResult
doubleTree _ = error "TspApprox.doubleTree not implemented"

matchingWeight :: [(Int, Int)] -> Int
matchingWeight _ = error "TspApprox.matchingWeight not implemented"

christofides :: [(Int, Int)] -> Maybe TourResult
christofides _ = error "TspApprox.christofides not implemented"
