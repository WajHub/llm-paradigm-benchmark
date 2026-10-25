You are a Haskell programming expert. Your task is to implement the required functions in accordance with the provided module interface.

Implement a Palindrome Tree (also known as Eertree) data structure in Haskell using the
module PalindromeTree. The Eertree is a linear-time data structure that implicitly
represents all distinct palindromic substrings of a string. It was introduced by
Mikhail Rubinchik and Arseny M. Shur in 2014.

- Implement `eertreeBuild :: Maybe String -> Int -> Maybe Eertree`: Build the palindrome
  tree for a given string of length `len` in O(n) time. The tree must include two
  imaginary root nodes at indices 0 and 1: root 0 has len = -1 (the "odd root"), root 1
  has len = 0 (the "even root"). After building, propagate occurrence counts from longer
  palindromes to shorter ones by traversing nodes in decreasing order of `len` and adding
  each node's `nodeCnt` to its `nodeSuffixLink`'s `nodeCnt`. The final `nodeCnt` of each
  node must equal the total number of times that palindrome appears as a substring in the
  input.

- Implement `eertreeCountDistinct :: Maybe Eertree -> Int`: Return the number of distinct
  palindromic substrings (i.e., the number of real nodes, excluding the two imaginary
  roots).

- Implement `eertreeCountOccurrences :: Maybe Eertree -> Maybe String -> Int -> Int`:
  Find the node in the tree whose palindrome matches `pattern` (using `nodeEndPos` to
  locate the substring in the stored string) and return its propagated `nodeCnt`. Return
  0 if the pattern is not found, not a palindrome, or any argument is Nothing.

- Implement `eertreeLongestLength :: Maybe Eertree -> Int`: Return the maximum `nodeLen`
  among all real nodes.

Constraints:
  - Input strings contain only lowercase Latin letters ('a'..'z').
  - `eertreeBuild Nothing n` with n > 0 must return Nothing.
  - `eertreeBuild (Just "") 0` must return a valid Eertree with only the two imaginary
    roots.
  - All query functions must return 0 on Nothing input without throwing.
  - Keep the contract (type definitions and exports) in `PalindromeTree.hs`.
  - Use idiomatic Haskell (immutable data, pure functions where possible).

General Requirements:
- Use idiomatic, pure Haskell.
- Prefer immutable data, algebraic data types, and total functions where practical.
- Model absence with `Maybe` instead of null pointers.
- Return ONLY raw Haskell code (no Markdown tags, no ```haskell blocks, no side text). Your code will be directly saved to a .hs file and compiled.
- Do not provide test runner code.

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