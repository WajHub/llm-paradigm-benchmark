# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in Haskell in the module Sudoku
(file Sudoku.hs). Implement isValid, candidates, solve and countSolutions with
exactly the signatures given in the module interface.

Board representation: a board is a flat `[Int]` of 81 cells in row-major order,
`index = row * 9 + col` (row and col are 0-based, 0..8). The value 0 means an empty
cell, 1..9 are digits. The nine 3x3 boxes start at rows/columns 0, 3 and 6.

- Implement `isValid :: [Int] -> Bool`: return True iff
  * the list has exactly 81 elements,
  * every element is in 0..9, and
  * no digit 1..9 appears more than once in any row, any column or any 3x3 box.
  Zeros are ignored (an all-zero board is valid). A complete, correct board is valid.
  Validity does NOT imply solvability.

- Implement `candidates :: [Int] -> Int -> Int -> [Int]` (`candidates grid row col`):
  precondition: the grid has 81 cells and row, col are in 0..8.
  * If the cell `grid !! (row * 9 + col)` is non-zero, return [].
  * Otherwise return the digits 1..9 that do not appear in that row, that column or
    that 3x3 box, in ascending order.
  Only the row, column and box of that cell matter; the rest of the grid does not
  have to be valid.

- Implement `solve :: [Int] -> Maybe [Int]`: return `Just` a complete board (81 cells,
  no zeros, valid, every non-zero input cell unchanged) that extends the input, or
  `Nothing` if `isValid grid` is False or no completion exists. An already complete
  valid board is returned unchanged (`Just grid`). If several solutions exist, any
  one of them is acceptable.

- Implement `countSolutions :: [Int] -> Int -> Int` (`countSolutions grid limit`):
  return the number of distinct complete valid boards extending the grid, but stop
  searching as soon as `limit` solutions have been found, so the result is
  `min total limit`. Return 0 when `limit <= 0` or `isValid grid` is False.
  For the empty board, `countSolutions (replicate 81 0) 2 == 2` and it must return
  promptly (the search must stop early, never enumerate everything).

Search requirements:
  - Use recursive backtracking that always branches on the empty cell with the
    FEWEST candidates (MRV heuristic). A cell with zero candidates is a dead end
    (backtrack immediately).
  - Naive backtracking over cells in row-major order is far too slow for some test
    puzzles (millions of nodes); with MRV they take only a few hundred nodes.
    Additional constraint propagation is allowed.
  - A board can be valid and still have no solution (an empty cell with no
    candidate, or a contradiction found only deeper in the search) -> Nothing / 0.
```
