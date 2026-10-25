import java.util.Arrays;

public class SudokuImpl extends Sudoku {

    private static final int SIZE = 9;
    private static final int CELLS = 81;
    private static final int ALL_DIGITS = 0b1111111110; // bits 1..9

    @Override
    public boolean isValid(int[] grid) {
        if (grid == null || grid.length != CELLS) {
            return false;
        }
        int[] rows = new int[SIZE];
        int[] cols = new int[SIZE];
        int[] boxes = new int[SIZE];
        for (int i = 0; i < CELLS; i++) {
            int v = grid[i];
            if (v < 0 || v > 9) {
                return false;
            }
            if (v == 0) {
                continue;
            }
            int r = i / SIZE;
            int c = i % SIZE;
            int b = boxOf(r, c);
            int bit = 1 << v;
            if ((rows[r] & bit) != 0 || (cols[c] & bit) != 0 || (boxes[b] & bit) != 0) {
                return false;
            }
            rows[r] |= bit;
            cols[c] |= bit;
            boxes[b] |= bit;
        }
        return true;
    }

    @Override
    public int[] candidates(int[] grid, int row, int col) {
        if (grid[row * SIZE + col] != 0) {
            return new int[0];
        }
        int used = 0;
        for (int i = 0; i < SIZE; i++) {
            used |= bitOf(grid[row * SIZE + i]);
            used |= bitOf(grid[i * SIZE + col]);
        }
        int br = (row / 3) * 3;
        int bc = (col / 3) * 3;
        for (int r = br; r < br + 3; r++) {
            for (int c = bc; c < bc + 3; c++) {
                used |= bitOf(grid[r * SIZE + c]);
            }
        }
        int available = ~used & ALL_DIGITS;
        int[] result = new int[Integer.bitCount(available)];
        int k = 0;
        for (int d = 1; d <= 9; d++) {
            if ((available & (1 << d)) != 0) {
                result[k++] = d;
            }
        }
        return result;
    }

    @Override
    public int[] solve(int[] grid) {
        if (!isValid(grid)) {
            return null;
        }
        Search search = new Search(grid, 1);
        search.run();
        return search.found > 0 ? search.solution() : null;
    }

    @Override
    public int countSolutions(int[] grid, int limit) {
        if (limit <= 0 || !isValid(grid)) {
            return 0;
        }
        Search search = new Search(grid, limit);
        search.run();
        return search.found;
    }

    private static int boxOf(int row, int col) {
        return (row / 3) * 3 + (col / 3);
    }

    private static int bitOf(int value) {
        return value == 0 ? 0 : (1 << value);
    }

    /** Backtracking search state with MRV cell selection. */
    private static final class Search {
        private final int[] cells;
        private final int[] rowMask = new int[SIZE];
        private final int[] colMask = new int[SIZE];
        private final int[] boxMask = new int[SIZE];
        private final int limit;
        private int found;
        private int[] firstSolution;

        Search(int[] grid, int limit) {
            this.cells = Arrays.copyOf(grid, CELLS);
            this.limit = limit;
            for (int i = 0; i < CELLS; i++) {
                int v = cells[i];
                if (v != 0) {
                    apply(i, v);
                }
            }
        }

        void run() {
            dfs();
        }

        int[] solution() {
            return Arrays.copyOf(firstSolution, CELLS);
        }

        private void apply(int idx, int d) {
            int r = idx / SIZE;
            int c = idx % SIZE;
            int bit = 1 << d;
            cells[idx] = d;
            rowMask[r] |= bit;
            colMask[c] |= bit;
            boxMask[boxOf(r, c)] |= bit;
        }

        private void undo(int idx, int d) {
            int r = idx / SIZE;
            int c = idx % SIZE;
            int bit = ~(1 << d);
            cells[idx] = 0;
            rowMask[r] &= bit;
            colMask[c] &= bit;
            boxMask[boxOf(r, c)] &= bit;
        }

        /** Returns true when the search should stop. */
        private boolean dfs() {
            int bestIdx = -1;
            int bestMask = 0;
            int bestCount = Integer.MAX_VALUE;

            for (int i = 0; i < CELLS; i++) {
                if (cells[i] != 0) {
                    continue;
                }
                int r = i / SIZE;
                int c = i % SIZE;
                int mask = ~(rowMask[r] | colMask[c] | boxMask[boxOf(r, c)]) & ALL_DIGITS;
                int count = Integer.bitCount(mask);
                if (count < bestCount) {
                    bestCount = count;
                    bestIdx = i;
                    bestMask = mask;
                    if (count <= 1) {
                        break;
                    }
                }
            }

            if (bestIdx == -1) {
                found++;
                if (firstSolution == null) {
                    firstSolution = Arrays.copyOf(cells, CELLS);
                }
                return found >= limit;
            }
            if (bestCount == 0) {
                return false;
            }

            int m = bestMask;
            while (m != 0) {
                int bit = m & -m;
                m ^= bit;
                int d = Integer.numberOfTrailingZeros(bit);
                apply(bestIdx, d);
                boolean stop = dfs();
                undo(bestIdx, d);
                if (stop) {
                    return true;
                }
            }
            return false;
        }
    }
}
