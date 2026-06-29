module PalindromeTree
  ( EertreeNode (..)
  , Eertree (..)
  , eertreeAlpha
  , eertreeBuild
  , eertreeCountDistinct
  , eertreeCountOccurrences
  , eertreeLongestLength
  ) where

eertreeAlpha :: Int
eertreeAlpha = 26

data EertreeNode = EertreeNode
  { nodeLen        :: Int
  , nodeSuffixLink :: Int
  , nodeChildren   :: [Int]
  , nodeCnt        :: Int
  , nodeEndPos     :: Int
  } deriving (Eq, Show)

data Eertree = Eertree
  { eertreeNodes  :: [EertreeNode]
  , eertreeSize   :: Int
  , eertreeLast   :: Int
  , eertreeStr    :: String
  , eertreeStrLen :: Int
  } deriving (Eq, Show)

eertreeBuild :: Maybe String -> Int -> Maybe Eertree
eertreeBuild _ _ = error "PalindromeTree.eertreeBuild not implemented"

eertreeCountDistinct :: Maybe Eertree -> Int
eertreeCountDistinct _ = error "PalindromeTree.eertreeCountDistinct not implemented"

eertreeCountOccurrences :: Maybe Eertree -> Maybe String -> Int -> Int
eertreeCountOccurrences _ _ _ = error "PalindromeTree.eertreeCountOccurrences not implemented"

eertreeLongestLength :: Maybe Eertree -> Int
eertreeLongestLength _ = error "PalindromeTree.eertreeLongestLength not implemented"
