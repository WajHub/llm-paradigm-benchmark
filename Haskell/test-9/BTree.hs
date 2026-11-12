module BTree
  ( BNode (..)
  , insertAll
  , deleteAll
  ) where

-- A B-tree node: strictly ascending keys; a leaf has no children, an internal
-- node with k keys has exactly k+1 children. The empty tree is BNode [] [].
data BNode = BNode
  { nodeKeys     :: [Int]
  , nodeChildren :: [BNode]
  } deriving (Eq, Show)

-- insertAll t keys
insertAll :: Int -> [Int] -> Maybe BNode
insertAll _ _ = error "BTree.insertAll not implemented"

-- deleteAll t keys deletions
deleteAll :: Int -> [Int] -> [Int] -> Maybe BNode
deleteAll _ _ _ = error "BTree.deleteAll not implemented"
