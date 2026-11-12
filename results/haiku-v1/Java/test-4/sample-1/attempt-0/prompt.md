You are a Java programming expert. Your task is to implement the required methods in accordance with the provided class or interface.

- Implement `maxValue`: Solve the 0/1 knapsack problem and return the maximum value attainable within the given capacity. Use dynamic programming (O(n * capacity)).
  * Return 0 if weights.length == 0 or capacity <= 0.
  * Each item may be selected at most once.
- Implement `solve`: Return a Result containing maxValue, a 0/1 selected array of length n, and totalWeight of selected items.
  * If n == 0 return Result(0, new int[0], 0). If capacity <= 0 return Result(0, new int[n], 0).
- DO NOT use greedy heuristics — they fail on cases like w=[10,20,30], v=[60,100,120], cap=50 (optimum = 220, greedy by ratio = 160).
- Selection must satisfy: sum(selected[i]*weights[i]) <= capacity; sum(selected[i]*values[i]) == maxValue.
- Keep the contract in Knapsack.java; put the solution in KnapsackImpl.java.

General Requirements:
- Use idiomatic Java.
- Use object-oriented design and model the domain with classes.
- Prefer standard library collections and utilities where appropriate.
- Return ONLY raw Java code (no Markdown tags, no ```java blocks, no side text). Your code will be directly saved to a .java file and compiled. Do not provide a main() method or test code.

public abstract class Knapsack {
    protected Knapsack() {}

    public static final class Result {
        public final int maxValue;
        public final int[] selected;      // length n; entries 0 or 1
        public final int totalWeight;
        public Result(int maxValue, int[] selected, int totalWeight) {
            this.maxValue = maxValue;
            this.selected = selected;
            this.totalWeight = totalWeight;
        }
    }

    public abstract int maxValue(int[] weights, int[] values, int capacity);
    public abstract Result solve(int[] weights, int[] values, int capacity);
}