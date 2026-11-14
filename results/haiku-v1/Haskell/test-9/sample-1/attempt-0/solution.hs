module BTree
  ( BNode (..)
  , insertAll
  , deleteAll
  ) where

import Data.List (foldl')

-- A B-tree node: strictly ascending keys; a leaf has no children, an internal
-- node with k keys has exactly k+1 children. The empty tree is BNode [] [].
data BNode = BNode
  { nodeKeys     :: [Int]
  , nodeChildren :: [BNode]
  } deriving (Eq, Show)

emptyTree :: BNode
emptyTree = BNode [] []

-- Helpers ---------------------------------------------------------------

setAt :: Int -> a -> [a] -> [a]
setAt i x xs = take i xs ++ [x] ++ drop (i + 1) xs

countLess :: Int -> [Int] -> Int
countLess k = length . takeWhile (< k)

insertSorted :: Int -> [Int] -> [Int]
insertSorted k xs = let (a, b) = span (< k) xs in a ++ k : b

member :: Int -> BNode -> Bool
member k (BNode ks cs) =
  k `elem` ks || (not (null cs) && member k (cs !! countLess k ks))

maxKey :: BNode -> Int
maxKey (BNode ks cs)
  | null cs = last ks
  | otherwise = maxKey (last cs)

minKey :: BNode -> Int
minKey (BNode ks cs)
  | null cs = head ks
  | otherwise = minKey (head cs)

isFull :: Int -> BNode -> Bool
isFull t n = length (nodeKeys n) == 2 * t - 1

-- Insertion -------------------------------------------------------------

-- Split child i (which must be full) of the given node.
splitChild :: Int -> BNode -> Int -> BNode
splitChild t (BNode ks cs) i =
  let y = cs !! i
      yk = nodeKeys y
      yc = nodeChildren y
      med = yk !! (t - 1)
      yLeft = BNode (take (t - 1) yk) (take t yc)
      yRight = BNode (drop t yk) (drop t yc)
      ks' = take i ks ++ [med] ++ drop i ks
      cs' = take i cs ++ [yLeft, yRight] ++ drop (i + 1) cs
  in BNode ks' cs'

-- Insert into a node that is known not to be full.
insertNonFull :: Int -> BNode -> Int -> BNode
insertNonFull t node@(BNode ks cs) k
  | null cs = BNode (insertSorted k ks) []
  | otherwise =
      let i = countLess k ks
          c = cs !! i
      in if isFull t c
           then
             let BNode ks' cs' = splitChild t node i
                 j = if k > ks' !! i then i + 1 else i
                 child' = insertNonFull t (cs' !! j) k
             in BNode ks' (setAt j child' cs')
           else BNode ks (setAt i (insertNonFull t c k) cs)

insertKey :: Int -> BNode -> Int -> BNode
insertKey t root k
  | member k root = root
  | isFull t root = insertNonFull t (splitChild t (BNode [] [root]) 0) k
  | otherwise = insertNonFull t root k

-- insertAll t keys
insertAll :: Int -> [Int] -> Maybe BNode
insertAll t keys
  | t < 2 = Nothing
  | otherwise = Just (foldl' (insertKey t) emptyTree keys)

-- Deletion --------------------------------------------------------------

-- Shrink the height if the root has no keys but a child.
shrink :: BNode -> BNode
shrink (BNode [] [c]) = c
shrink n = n

-- Delete k from the subtree rooted at node; k must be present in it.
deleteFrom :: Int -> Int -> BNode -> BNode
deleteFrom t k (BNode ks cs)
  | null cs = BNode (filter (/= k) ks) []
  | k `elem` ks = deleteInternal
  | otherwise = deleteDescend
  where
    deleteInternal =
      let i = countLess k ks
          y = cs !! i
          z = cs !! (i + 1)
      in if length (nodeKeys y) >= t
           then
             let k' = maxKey y
             in BNode (setAt i k' ks) (setAt i (deleteFrom t k' y) cs)
           else if length (nodeKeys z) >= t
             then
               let k'' = minKey z
               in BNode (setAt i k'' ks) (setAt (i + 1) (deleteFrom t k'' z) cs)
             else
               let merged = BNode (nodeKeys y ++ [k] ++ nodeKeys z)
                                  (nodeChildren y ++ nodeChildren z)
                   ks' = take i ks ++ drop (i + 1) ks
                   cs' = take i cs ++ [merged] ++ drop (i + 2) cs
               in BNode ks' (setAt i (deleteFrom t k merged) cs')

    deleteDescend =
      let i = countLess k ks
          c = cs !! i
          hasLeft = i > 0
          hasRight = i < length cs - 1
          leftRich = hasLeft && length (nodeKeys (cs !! (i - 1))) >= t
          rightRich = hasRight && length (nodeKeys (cs !! (i + 1))) >= t
          (ks', cs', j)
            | length (nodeKeys c) >= t = (ks, cs, i)
            | leftRich = rotateRight i c
            | rightRich = rotateLeft i c
            | hasRight = mergeRight i c
            | otherwise = mergeLeft i c
      in BNode ks' (setAt j (deleteFrom t k (cs' !! j)) cs')

    rotateRight i c =
      let l = cs !! (i - 1)
          lk = nodeKeys l
          lc = nodeChildren l
          l' = BNode (init lk) (if null lc then [] else init lc)
          c' = BNode (ks !! (i - 1) : nodeKeys c)
                     (if null lc then nodeChildren c else last lc : nodeChildren c)
          ks' = setAt (i - 1) (last lk) ks
          cs' = setAt (i - 1) l' (setAt i c' cs)
      in (ks', cs', i)

    rotateLeft i c =
      let r = cs !! (i + 1)
          rk = nodeKeys r
          rc = nodeChildren r
          r' = BNode (tail rk) (drop 1 rc)
          c' = BNode (nodeKeys c ++ [ks !! i]) (nodeChildren c ++ take 1 rc)
          ks' = setAt i (head rk) ks
          cs' = setAt (i + 1) r' (setAt i c' cs)
      in (ks', cs', i)

    mergeRight i c =
      let r = cs !! (i + 1)
          m = BNode (nodeKeys c ++ [ks !! i] ++ nodeKeys r)
                    (nodeChildren c ++ nodeChildren r)
          ks' = take i ks ++ drop (i + 1) ks
          cs' = take i cs ++ [m] ++ drop (i + 2) cs
      in (ks', cs', i)

    mergeLeft i c =
      let l = cs !! (i - 1)
          m = BNode (nodeKeys l ++ [ks !! (i - 1)] ++ nodeKeys c)
                    (nodeChildren l ++ nodeChildren c)
          ks' = take (i - 1) ks ++ drop i ks
          cs' = take (i - 1) cs ++ [m] ++ drop (i + 1) cs
      in (ks', cs', i - 1)

-- deleteAll t keys deletions
deleteAll :: Int -> [Int] -> [Int] -> Maybe BNode
deleteAll t keys deletions
  | t < 2 = Nothing
  | otherwise = Just (foldl' step root0 deletions)
  where
    root0 = foldl' (insertKey t) emptyTree keys
    step r k
      | member k r = shrink (deleteFrom t k r)
      | otherwise = r
