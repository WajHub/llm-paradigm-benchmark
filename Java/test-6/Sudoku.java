public abstract class Sudoku {
    protected Sudoku() {}

    public abstract boolean isValid(int[] grid);
    public abstract int[] candidates(int[] grid, int row, int col);
    public abstract int[] solve(int[] grid);
    public abstract int countSolutions(int[] grid, int limit);
}
