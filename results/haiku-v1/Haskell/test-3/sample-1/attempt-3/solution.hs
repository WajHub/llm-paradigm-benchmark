module PalindromeTree
  ( EertreeNode (..)
  , Eertree (..)
  , eertreeAlpha
  , eertreeBuild
  , eertreeCountDistinct
  , eertreeCountOccurrences
  , eertreeLongestLength
  ) where

import qualified Data.IntMap.Strict as IM
import qualified Data.Map.Strict as M
import Data.Array (Array, listArray, (!))
import Data.List (foldl', sortBy)
import Data.Ord (Down (..), comparing)

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

-- Internal build state
data BState = BState
  { bNodes :: IM.IntMap EertreeNode
  , bTrans :: M.Map (Int, Char) Int
  , bSize  :: Int
  , bLast  :: Int
  }

initState :: BState
initState = BState
  { bNodes = IM.fromList
      [ (0, EertreeNode (-1) 0 [] 0 (-1))
      , (1, EertreeNode 0 0 [] 0 (-1))
      ]
  , bTrans = M.empty
  , bSize  = 2
  , bLast  = 1
  }

stepBuild :: Array Int Char -> BState -> (Int, Char) -> BState
stepBuild arr st (i, c) =
  let nodes = bNodes st
      lenOf v = nodeLen (nodes IM.! v)
      linkOf v = nodeSuffixLink (nodes IM.! v)
      findLink v =
        let j = i - lenOf v - 1
        in if j >= 0 && arr ! j == c then v else findLink (linkOf v)
      cur = findLink (bLast st)
  in case M.lookup (cur, c) (bTrans st) of
       Just w ->
         st { bNodes = IM.adjust bump w nodes
            , bLast  = w
            }
       Nothing ->
         let newLen = lenOf cur + 2
             newId  = bSize st
             lnk
               | newLen == 1 = 1
               | otherwise   =
                   M.findWithDefault 1 (findLink (linkOf cur), c) (bTrans st)
             node   = EertreeNode newLen lnk [] 1 i
         in st { bNodes = IM.insert newId node nodes
               , bTrans = M.insert (cur, c) newId (bTrans st)
               , bSize  = newId + 1
               , bLast  = newId
               }
  where
    bump nd = nd { nodeCnt = nodeCnt nd + 1 }

buildTree :: String -> Eertree
buildTree s =
  Eertree
    { eertreeNodes  = IM.elems finalNodes
    , eertreeSize   = bSize st
    , eertreeLast   = bLast st
    , eertreeStr    = s
    , eertreeStrLen = n
    }
  where
    n   = length s
    arr = listArray (0, n - 1) s :: Array Int Char
    st  = foldl' (stepBuild arr) initState (zip [0 ..] s)

    order = map fst
          $ sortBy (comparing (Down . nodeLen . snd))
          [ (v, nd) | (v, nd) <- IM.toList (bNodes st), v >= 2 ]

    propagate m v =
      let nd  = m IM.! v
          c   = nodeCnt nd
          l   = nodeSuffixLink nd
      in IM.adjust (\x -> x { nodeCnt = nodeCnt x + c }) l m

    propagated = foldl' propagate (bNodes st) order

    childMap = IM.fromListWith (++)
      [ (p, [w]) | ((p, _), w) <- M.toList (bTrans st) ]

    finalNodes = IM.mapWithKey
      (\k nd -> nd { nodeChildren = IM.findWithDefault [] k childMap })
      propagated

eertreeBuild :: Maybe String -> Int -> Maybe Eertree
eertreeBuild Nothing n
  | n == 0    = Just (buildTree "")
  | otherwise = Nothing
eertreeBuild (Just s) n
  | n < 0          = Nothing
  | length s == n  = Just (buildTree s)
  | otherwise      = Nothing

eertreeCountDistinct :: Maybe Eertree -> Int
eertreeCountDistinct Nothing = 0
eertreeCountDistinct (Just t) = max 0 (eertreeSize t - 2)

eertreeCountOccurrences :: Maybe Eertree -> Maybe String -> Int -> Int
eertreeCountOccurrences (Just t) (Just p) _
  | pl == 0 = 0
  | otherwise =
      case [ nodeCnt nd
           | nd <- drop 2 (eertreeNodes t)
           , nodeLen nd == pl
           , matches nd
           ] of
        (x : _) -> x
        []      -> 0
  where
    pl = length p
    matches nd =
      let start = nodeEndPos nd - pl + 1
      in start >= 0 && take pl (drop start (eertreeStr t)) == p
eertreeCountOccurrences _ _ _ = 0

eertreeLongestLength :: Maybe Eertree -> Int
eertreeLongestLength Nothing = 0
eertreeLongestLength (Just t) =
  maximum (0 : [ nodeLen nd | nd <- drop 2 (eertreeNodes t) ])
