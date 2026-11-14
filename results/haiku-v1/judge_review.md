# Judge review: haiku-v1

Scores 1-5 per criterion with the judge's reason for each. *Reasoning summary* is the judge's own summarized thinking before it answered. Judge version 1 rows have no per-criterion rationale (rerun `python harness/judge.py --rejudge` to get it).

## C test-1 (sample 1, attempt 0): mean 4.00

Code: [C/test-1/sample-1/attempt-0/solution.c](C/test-1/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SDRGK6LaA72C2WhcxA`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is clean procedural C: small static helpers (geo_cross, geo_on_segment, geo_segments_intersect), explicit loops, data passed through structs, and straightforward control flow with early returns. Monotone-chain hull built on qsort is the standard imperative approach. Cleanup uses a single exit path in places, with early-break loops. A 5 would require fewer inline loops in the big functions, e.g. extracting hull construction and the 'inside' test into helpers. |
| language | 4 | Uses static helpers, qsort with a comparator, size_t for sizes, calloc/malloc checks, and a bounded strncpy wrapper that guarantees termination. Naming is consistent with a geo_ prefix. Minor departures: the contract has const pointers but geo_cmp_points casts properly; the cast of calloc/malloc results is unnecessary in C; geo_abs reimplements fabs from <math.h>; the `for (size_t i = u - 1; i-- > 0; )` idiom is a bit cryptic; the dedupe uses per-axis epsilon after sorting. Mixing int num_vertices with size_t requires casts but they are handled. |
| readability | 4 | Names are clear and comments mark the hull phases and the collision steps. Functions are mostly short, but calculate_clean_minkowski_sum is long, mixing point generation, dedupe, hull and result copy. The reverse upper-hull loop and the `k--` trailing comment need a moment to follow. Splitting it into helpers would earn a 5. |
| design | 4 | Good separation: geometry primitives, name copy, allocation/free pairs, and collision implemented via the Minkowski sum of obstacle and negated robot, as the spec requires. Ownership is clear and error paths free pts/hull/neg/cspace. Weaknesses: the Minkowski sum is computed as O(nm log nm) brute-force hull of all pairwise sums rather than an edge-merge, which is acceptable; hull construction is not factored into a reusable convex_hull function; the temporary Polygon allocation for the negated robot is heavier than needed; the final copy from hull to result could be a memcpy. |

**Overall:** The code is solid procedural C with static helpers, qsort, checked allocations and consistent cleanup, and the collision check follows the C-space approach via the Minkowski sum with the negated robot. Small deductions come from the long calculate_clean_minkowski_sum, the hand-rolled geo_abs and copy loop, and the lack of a separate convex-hull helper. Overall it is idiomatic and easy to follow.

**Anti-patterns:**
- reimplementing fabs (geo_abs) instead of using math.h
- long function mixing point generation, dedupe, hull building and result copy
- manual loop copy instead of memcpy for hull to result vertices
- unnecessary casts on malloc/calloc results

## C test-2 (sample 1, attempt 0): mean 4.00

Code: [C/test-2/sample-1/attempt-0/solution.c](C/test-2/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SDRDqapRFte8jZg2f3`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is procedural: a MinHeap struct operated on by static functions (heap_init, heap_push, heap_pop, heap_free), explicit state mutation, and a clear loop in dijkstra. It uses lazy deletion with a visited array and the heap's capacity is pre-sized to E+1 so no resizing occurs. A 5 would break the long dijkstra into smaller steps (allocation/init helper, relaxation) and use a sift-up/sift-down abstraction instead of inlined loops. |
| language | 4 | It uses static helpers, size_t casts, calloc, realloc with a temporary pointer, const on the graph and result parameters, and isinf/INFINITY. Minor departures: needless casts of malloc results (a C++ habit), a redundant per-element re-initialisation loop after calloc in create_graph, a `long total_edges` that is cast to int, and the `visited[u]` check duplicates the `item.dist > distances[u]` check. A silent defensive return in heap_push hides errors. |
| readability | 4 | Names are clear (HeapItem, MinHeap, heap_push, visited, nd) and the heap functions are short and understandable. dijkstra is long (about 60 lines) with repeated cleanup blocks, and the reconstruct_path two-pass logic with a cycle guard takes some reading. Comments are sparse and used where helpful (e.g. the NaN rejection). Splitting dijkstra would earn a 5. |
| design | 4 | The min-heap is a separate encapsulated component and the result and graph have matched free functions. The error cleanup in dijkstra is duplicated twice rather than using a single goto cleanup. The heap is sized from the total edge count, which is correct but requires a pass over the edges. heap_push silently ignores overflow rather than being provably safe. The path is computed in two passes (count, then fill), which is sensible. A single cleanup label and a smaller dijkstra would improve it. |

**Overall:** A solid procedural C implementation with a well-encapsulated static min-heap, proper NULL and bounds checks, const-correct parameters, and a safe realloc pattern. Weaknesses are the long dijkstra with duplicated error cleanup, the redundant initialisation loop after calloc, unnecessary malloc casts, and the silently ignoring defensive guard in heap_push.

**Anti-patterns:**
- duplicated manual cleanup blocks instead of a single goto cleanup label
- redundant re-initialisation loop after calloc in create_graph
- needless casts of malloc/calloc results
- silent no-op in heap_push when the capacity is exceeded
- long dijkstra function mixing allocation, init and the main loop

## C test-3 (sample 1, attempt 0): mean 4.25

Code: [C/test-3/sample-1/attempt-0/solution.c](C/test-3/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RsJB7tAMgXLDSMRVLo`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | The code is straightforward procedural C. It uses an opaque struct built by one function, static helper functions, explicit loops, and in-place mutation of the arrays. Data flow is clear: build, then count propagation, then queries. The `eertree_get_link` helper is a clean procedural extraction. One more point would need nothing significant; this is close to what an experienced C programmer would write. |
| language | 4 | It uses `static` for the helper, `const` on read-only pointers, `calloc` with a NULL check, a single cleanup path for partial allocation failure, `memcpy` and `memcmp` from the standard library, and `size_t` casts for allocation sizes. Small departures: `while (1)` with the return inside, and `(Eertree*)` casts on malloc/calloc results, which are unnecessary in C. The count propagation loop over creation index is justified in a comment. A 5 would drop the redundant casts. |
| readability | 4 | Names are clear (`eertree_get_link`, `cur`, `w`, `idx`). The build function is moderately long, but each phase is delimited by short comments: imaginary roots, the main loop, count propagation. The comment explaining why decreasing creation index is a valid order is useful. Locals `c`, `l`, `p` are short but conventional. The 'new node' branch is inlined in `eertree_build` and could be a helper, which would earn a 5. |
| design | 4 | Responsibilities are well divided: the link-walking helper, build, and small, focused query functions, with each function owning one task. The capacity `len + 3` is exact for the maximum node count. Input validation, including the lowercase check, is done upfront, and the cleanup on allocation failure is correct. Ownership is simple, with a single `eertree_free`. Weaknesses: the node-creation logic is embedded in the build loop, and `count_occurrences` does a linear scan over the nodes rather than walking the tree from the root, which is acceptable under the contract's `end_pos` hint. |

**Overall:** The solution is clean procedural C. `eertree_get_link` is a `static` helper, parameters are `const`-correct, the allocation-failure path frees everything, and the standard `memcpy`/`memcmp` are used. Small blemishes are the redundant malloc casts, the long-ish `eertree_build` with inline node creation, and the linear scan in `eertree_count_occurrences`. Overall it is idiomatic and easy to follow.

**Anti-patterns:**
- unnecessary casts of calloc/malloc results
- node-creation logic inlined in the build loop rather than a helper

## C test-4 (sample 1, attempt 0): mean 3.75

Code: [C/test-4/sample-1/attempt-0/solution.c](C/test-4/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SDRCbxNkTCeuYks8Wt`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is procedural DP with explicit loops, in-place mutation and a backward capacity loop for the 1D table in knapsack_max_value. Early returns handle guards and an explicit free ends each path. The 1D rolling array is the classic form. In knapsack_solve the flattened 2D table and backtracking are also standard. Because the DP fill and the reconstruction sit inline in one function, it falls just short of a 5. |
| language | 4 | It uses calloc with (size_t) casts, const pointer parameters from the contract, and size_t index arithmetic for the flattened table. Cleanup on allocation failure is correct. The casts on malloc/calloc are unnecessary in C. The repeated `(size_t)i * cols + c` is verbose, and no static helper or macro is used. The `w < 0` handling is inconsistent between the two functions. These keep it at 4. |
| readability | 4 | Names are clear (dp, cols, rows, cand, best), and a comment documents dp[i][c] and the reconstruction step. The long index expressions in knapsack_solve are somewhat noisy. The function is moderately long but still easy to follow. A small index helper would make it a 5. |
| design | 3 | The three functions match the contract and ownership is clear: free_knapsack_result frees both the inner array and the struct. The solve function does allocation, DP fill and reconstruction in one body, with no static helpers. The 1D and 2D DP logic is duplicated across the two public functions, though the 2D table is justified because reconstruction needs it. Extracting static helpers for table building and backtracking would raise the score. |

**Overall:** This is a correct, conventional C DP solution: a 1D rolling table for the value-only function and a full 2D table with backtracking for the result. Error paths free memory properly and the NULL-safe free function is correct. The main weaknesses are the single long knapsack_solve with no static helpers, the noisy flattened-index expressions, and the redundant malloc casts.

**Anti-patterns:**
- unnecessary casts of malloc/calloc results
- long inline index arithmetic instead of a helper or macro
- monolithic knapsack_solve combining allocation, DP fill and backtracking
- DP recurrence duplicated across the two public functions

## C test-5 (sample 1, attempt 0): mean 3.25

Code: [C/test-5/sample-1/attempt-0/solution.c](C/test-5/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SDRCMTs1msFWEZV5LJ`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The solution is a classic procedural recursive-descent parser, with one function per grammar rule (parse_expr, parse_term, parse_unary, parse_power, parse_primary). Parser state is held in a small `Parser` struct passed by pointer, and there is no global state. Left-associative operators are handled with `for(;;)` loops. The evaluator is a recursive switch over `NodeKind`. It would earn a 5 if parse_primary were split into number, identifier and call sub-routines, which would keep the control flow flatter. |
| language | 3 | It uses static helpers, `calloc`, `isspace((unsigned char)...)`, `size_t`, `strtod`, `fmod` and `isfinite`. Allocation failures are checked and the ownership cleanup is correct. Departures from common C practice: `func` is stored as `int` instead of `FuncId`; the number is copied into a malloc'd buffer just to call `strtod`, where `strtod` could parse directly from the source; the function-name lookup is an if/else strcmp chain instead of a static table; `(AstNode *)calloc` casts are unnecessary; and `strtod` accepts a leading '.' that the spec's NUMBER may not allow. |
| readability | 3 | Names are clear (`skip_ws`, `make_binary`, `checked_pow`, `make_result`), the grammar mapping is easy to follow, and the evaluator is straightforward. However, `parse_primary` is roughly 100 lines with deeply nested branches and an `ok` flag that threads through argument parsing, which hurts readability. The `nchild == 1` versus else split in `NODE_CALL` is also somewhat implicit. |
| design | 3 | Parsing and evaluation are separated, there are constructor helpers with cleanup on failure, and `make_result` enforces value 0.0 on error. Weaknesses: `AstNode` is a fat struct with unused fields per kind (num, name, op, func), not a union. `parse_term` and `parse_expr` duplicate nearly the same loop, which could be parameterised. Function name, arity and ID are handled by a repeated if-chain instead of a lookup table. The oversized `parse_primary` mixes number, identifier and call parsing. The evaluator's call handling dispatches on arity before function, which is awkward. |

**Overall:** The code is a sound procedural recursive-descent parser with correct ownership and cleanup on every error path, static helpers and a clean evaluator switch. Its idiomaticity is reduced by the long, nested parse_primary, the strcmp chain for function lookup, the temporary malloc buffer for number parsing and the `int func` field. Duplicated binary-operator loops and a non-union AST node add further structural looseness.

**Anti-patterns:**
- monolithic parse_primary doing number, identifier and call parsing
- if/else strcmp chain instead of a static function table
- needless malloc'd temporary buffer for strtod
- enum value stored as int (`int func`)
- duplicated left-assoc loop in parse_term and parse_expr
- fat struct with unused fields instead of a tagged union

## C test-6 (sample 1, attempt 0): mean 3.25

Code: [C/test-6/sample-1/attempt-0/solution.c](C/test-6/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SDyACvHaCSfS4k8VTA`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Procedural decomposition is clean: static helpers (check_valid, init_masks, search), a SearchCtx struct passed explicitly, no globals, and in-place mutate/undo backtracking on the working grid and bitmask arrays. The MRV scan with early exit on pc==1 and immediate dead-end on pc==0 is a classic imperative treatment. Small blemishes are that solve and count duplicate the setup code and that search takes five loose state parameters instead of one struct. Grouping them would be a 5. |
| language | 3 | Uses static helpers, const on read-only parameters, memcpy, and unsigned bitmasks with 1u<<v and a 0x3FEu mask. The needless (int*) casts on malloc are a C++ habit. The dead variable b in sudoku_candidates is silenced with (void)b. The popcount9 loop is hand-rolled, and the three-statement-per-line `int r = ..., c = ..., b = ...` style is acceptable. The `int v; v = ...` split declaration is unidiomatic. Removing these would earn a 5. |
| readability | 3 | Names (rows, cols, boxes, bestmask, empties) are clear and functions are short. There are no comments explaining the bitmask layout (bit d for digit d, 0x3FE) or the MRV logic. The box index expression (r/3)*3+(c/3) is repeated inline many times, and the unused `b` plus `(void)b` in sudoku_candidates is noise. The `!(bestmask & (1u<<d))` check recomputes the bit, and the loop pattern is slightly redundant. |
| design | 3 | Bitmask state makes search efficient, and a single search routine serves both solve and count via limit. Ownership is clear: g freed after search, the result is a fresh allocation, and there are no leaks. Weaknesses: sudoku_is_valid is a pure wrapper of check_valid; the setup code (copy, init_masks, empties count) is duplicated across solve and count; the row/col/box index and the set/clear-bit logic are repeated rather than factored into helpers; solve mallocs twice (g then result) where it could reuse one allocation; and sudoku_candidates does not reuse the shared mask logic. |

**Overall:** The solution is a sound procedural backtracker with bitmask state, MRV selection, and explicit context passing, and it manages memory correctly. It loses points for duplicated setup in solve and count, the unused variable hidden with (void)b, malloc casts, and a lack of helpers for repeated index and mask updates. Comments explaining the bit encoding are absent.

**Anti-patterns:**
- duplicated setup code in sudoku_solve and sudoku_count_solutions
- dead variable b silenced with (void)b
- unnecessary casts on malloc
- trivial wrapper sudoku_is_valid around check_valid
- box index and bit set/clear logic repeated inline instead of helpers
- redundant second allocation in sudoku_solve

## C test-7 (sample 1, attempt 0): mean 3.25

Code: [C/test-7/sample-1/attempt-0/solution.c](C/test-7/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RsJ7te2ccQ48AeKcdb`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is plainly procedural. `gotoh_fill` fills the three flat matrices with nested loops, and `alignment_align` runs an explicit traceback state machine over M/X/Y. Data flows through pointers and mutable indices, and a helper has a clear job. The traceback uses magic ints (0/1/2) for the state instead of an enum, and `alignment_align` is long, doing traceback, reversal and allocation in one body. An enum and a separate traceback helper would earn a 5. |
| language | 3 | Uses `static` helpers, `size_t` indices, `const char*` parameters, a flat row-major array, and checked mallocs. It also frees correctly on every error path, and `free_alignment_result(NULL)` is handled. Weaknesses: a `ll` typedef and `GOTOH_NEG` macro instead of `long long` or `int64_t` and a `static const`, casts of malloc results (unneeded in C), C89-style declarations at the top, a bare `{}` block in the middle of the function, and a failed allocation returning 0 from `alignment_score`. The traceback also loses the `(int)` score check, which is minor. The `i>0&&j>0` and `i>0` guards inside `gotoh_fill` are partly redundant. The duplicated cleanup is also not done with a `goto cleanup` idiom. |
| readability | 3 | Comments mark each matrix (`M: column a[i-1] over b[j-1]`, `X`, `Y`) and names like `gotoh_fill` and `ll_max3` are clear. Single-letter names (M, X, Y, p, s, v) and the numeric state codes 0/1/2 make the traceback harder to follow. The long `alignment_align` with nested blocks and a repeated cleanup sequence hurts readability. |
| design | 3 | Sharing `gotoh_fill` between `alignment_score` and `alignment_align` avoids duplicating the DP. Using three full matrices is acceptable for the task. However, `alignment_align` mixes traceback, buffer management and result construction, and the cleanup code is repeated across three exit paths. `alignment_score` could use O(m) memory but allocates the full matrices. The traceback could be extracted into its own function. |

**Overall:** The solution is a clean procedural Gotoh implementation: `gotoh_fill` is shared by both entry points, allocation failures are checked, and everything is freed. The traceback in `alignment_align` relies on magic state numbers and is one long function with repeated cleanup blocks. Minor C-style issues such as malloc casts, the `ll` typedef, and a bare reversal block keep it from being fully idiomatic.

**Anti-patterns:**
- magic integer state codes (0/1/2) instead of an enum
- long function mixing traceback, reversal and allocation
- duplicated cleanup code on multiple error paths instead of goto cleanup
- casting malloc results
- anonymous block in the middle of a function for the reversal step
- full O(nm) matrices allocated for score-only computation

## C test-8 (sample 1, attempt 0): mean 3.50

Code: [C/test-8/sample-1/attempt-0/solution.c](C/test-8/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RsJ5uiJipcLwdovDAh`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is procedural: static helpers (build_mst, odd_vertices, min_matching, preorder, tour_cost) pass data through arrays and out-pointers (parent, O, pairA/pairB, cnt). Control flow is plain loops, and Hierholzer uses an explicit stack with CSR adjacency and edge-used flags. This is what an experienced C programmer would write. Reaching 5 would need tsp_christofides split into smaller steps (Euler circuit, shortcut), since it is currently a long monolith. |
| language | 3 | It uses static helpers, const on read-only pointers, size_t casts for allocation sizes, calloc for zeroed arrays, and a local INF constant. Weaknesses: malloc/calloc results are never checked in the helpers (only make_result checks the struct, not r->tour). The casts on malloc are unnecessary in C. dist_pt hand-rolls abs instead of using abs. Recursive preorder does an O(n) scan per call, which is acceptable for n <= 40. On the n==1 early return the tour is fine, but a failed tour allocation is not handled. Checked allocation with a goto-cleanup error path would earn a higher score. |
| readability | 4 | Names are clear (build_mst, odd_vertices, min_matching) and the doc comments are useful. The bitmask DP and matching reconstruction are easy to follow, and the Hierholzer section is commented. tsp_christofides is about 100 lines with many temporaries and a long free list at the end, which hurts readability. Names like eu/ev/deg2/E are terse. Splitting out the Euler circuit and the shortcut would make it a 5. |
| design | 3 | There is good reuse: build_mst is shared by all four entry points, and min_matching serves both the weight query and pair reconstruction through optional out-parameters. tour_cost and make_result avoid duplication. The weaknesses are the monolithic tsp_christofides (edge list, CSR build, Hierholzer and shortcut inline), the duplicated n==1 handling in both tour functions, and the pair-reconstruction logic that repeats the DP transition. Extracting build_multigraph, euler_circuit and shortcut helpers would improve it. |

**Overall:** The solution is solid procedural C with static helpers, a shared build_mst, a bitmask DP matching and a CSR-based Hierholzer. It loses points mainly for tsp_christofides being a long monolithic function with many temporaries and a manual free list, and for mostly missing allocation checks. Duplicated n==1 handling and DP reconstruction logic are minor design blemishes.

**Anti-patterns:**
- unchecked malloc/calloc results in helpers and for r->tour
- one very long function (tsp_christofides) with a long manual free list
- DP transition logic duplicated between table fill and reconstruction
- hand-rolled abs in dist_pt
- unnecessary casts of malloc results

## C test-9 (sample 1, attempt 0): mean 3.75

Code: [C/test-9/sample-1/attempt-0/solution.c](C/test-9/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RsxavB53smWrqK3HLW`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is procedural: small static helpers (split_child, merge_children, rotate_left/right, remove_key_at) mutate nodes in place, and the root is updated through a BTreeNode** in insert_key. Iterative descent in insert_nonfull and delete_key avoids needless recursion, with recursion only where the predecessor/successor delete needs it. It would reach 5 with less manual shifting and the shared logic factored out, but the paradigm fit is already strong. |
| language | 3 | Uses static helpers, const on contains' parameter, size_t casts in calloc, and a free_btree that accepts NULL. Departures: the manual shift loops could be memmove, the calloc results for keys/children in new_node are never checked, split_child and insert_key dereference new_node results unchecked, and there are C99 mid-block declarations alongside C89-style `int j;` declarations. Using memmove and checking every allocation would earn a 5. |
| readability | 4 | Names are clear (max_key, min_key, rotate_right, merge_children), the functions are short, and the comments on split/merge/rotate are useful. Case 2 and case 3 of delete_key sit inside one loop with a continue after the merge, which is a little dense. The unchecked `int ci = i;` aliasing and the manual shifting loops add noise. Splitting delete_key into a helper like ensure_child_has_t_keys would bring it to 5. |
| design | 4 | Decomposition follows the CLRS operations, with a shared merge_children used for both 2c and 3b, rotations separated out, and contains used for the membership pre-checks. Nodes are allocated with a uniform capacity (2t keys, 2t+1 children) and free_shell handles ownership consistently, so merges and root shrinking don't leak. Weaknesses: the shifting code is duplicated across many helpers, there is no allocation-failure handling, and delete_key is long. Extracting a fix-child helper and array-shift helpers would improve it. |

**Overall:** This is a clean procedural CLRS B-tree with static helpers, iterative descent, and consistent ownership through free_shell and free_tree_rec. The algorithm decomposition (split_child, merge_children, rotate_left/right, contains pre-checks) is sound. It loses points for missing allocation-failure handling, hand-written shift loops rather than memmove, and a long delete_key that inlines the child-fixing logic.

**Anti-patterns:**
- unchecked calloc results in new_node (keys/children) and unchecked new_node in split_child/insert_key
- hand-rolled element-shifting loops instead of memmove
- long delete_key function mixing cases 2 and 3 including child rebalancing

## C test-10 (sample 1, attempt 0): mean 3.50

Code: [C/test-10/sample-1/attempt-0/solution.c](C/test-10/sample-1/attempt-0/solution.c) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RsJ7taBk2a7keVEMfq`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is plain procedural C. It uses explicit loops, a stable partition into scratch buffers `lbuf`/`gbuf`, and a `while (1)` loop that carries state (`work`, `curlen`, `kk`). The binary search in `median_two_sorted` is cleanly iterative. Flags such as `ok` and `bool* ok` passed into `append_pivot` carry error state and are slightly clunky. Setting `ok` and then checking it twice, and the `while(1)`/`break` control flow, are a bit awkward. Splitting out a partition step and using goto-style cleanup or early returns would earn one more point. |
| language | 4 | The code uses `static` helpers, `size_t` casts on allocation sizes, `memcpy`, `qsort` with a safe comparator `(x>y)-(x<y)`, and `long long` for index arithmetic. It checks `malloc`/`realloc` results and frees on error paths. Small blemishes: the unneeded `(int*)` casts on `malloc`, `while (1)` instead of `for (;;)`, the output parameter `bool* ok`, and the unneeded `xs == NULL` check with `n <= 0`. It also uses the hand-rolled `insertion_sort` for 5 elements, which is reasonable. `median_of_medians` returns false on an allocation failure, conflating that with n == 0. |
| readability | 3 | Names like `median_of_medians`, `append_pivot`, `lm` and `rm` are reasonable, and the comments in the binary search explain the invariant. However, `select_kth` is a long function that mixes allocation, the loop, partitioning and cleanup. `median_two_sorted` has terse names (`lm`, `hr`, `have`) and uppercase `N`, `A`, `B`. The left-max/right-min logic is repeated inline. Extracting helpers would improve it. |
| design | 3 | The design is mostly decomposed: `cmp_int`, `insertion_sort`, `append_pivot` and `get_at` are `static`. But `select_kth` is monolithic, with partitioning inline, and it allocates three full-size buffers (`work`, `lbuf`, `gbuf`) even though it needs fewer. `append_pivot` carries a three-pointer growth interface plus an `ok` flag, which is clunky. `median_two_sorted` is a single function whose max/min selection could be helper functions. It does swap to search the shorter source, uses no heap, and has the right complexity. Cleanup is repeated across several paths. |

**Overall:** The solution is solid procedural C with correct use of `static` helpers, `memcpy`, `qsort`, `size_t` casts and 64-bit index arithmetic. The binary-search median uses no heap and the allocation failures are handled. Its weaknesses are the long `select_kth`, the clunky `append_pivot`/`ok` error handling, terse names in `median_two_sorted`, and the inline partition and max/min logic that could be extracted.

**Anti-patterns:**
- long monolithic select_kth mixing allocation, partitioning and cleanup
- ok-flag out-parameter threaded through append_pivot instead of returning status
- redundant (int*) casts on malloc
- repeated inline left-max/right-min logic instead of a helper
- three full-size scratch buffers allocated up front

## Haskell test-1 (sample 1, attempt 1): mean 4.25

Code: [Haskell/test-1/sample-1/attempt-1/solution.hs](Haskell/test-1/sample-1/attempt-1/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SE2wR9P8ohXi5boe5r`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | The code is pure and declarative: the hull is a fold (`foldl step []`) over sorted points, the Minkowski cloud is a list comprehension, and collision is a disjunction of predicates (`containsPoint`, `segmentsIntersect` via `any`). There is no mutation or imperative emulation. A 5 would need a few rough spots fixed, such as the partial `head` and the `length` checks, and a stricter fold. |
| language | 4 | It uses `Maybe` with pattern matching, `comparing`, `on`, `groupBy`, `sortBy` and `where` clauses. `map head . groupBy` is a partial function, even though groupBy never yields empty groups. `step` is written as a function with a guard that falls through to a second equation, which is clever but unusual. `foldl` is used lazily instead of `foldl'`. `length sorted < 3` and `length poly < 3` traverse whole lists where a pattern match would do. Using `Data.List.nub` or `NonEmpty.group` would avoid `head`. |
| readability | 4 | Names are clear (`cross`, `minkowskiCloud`, `containsPoint`, `segmentsIntersect`, `onSegment`), signatures are present, and the haddock comments are useful. The `step` fall-through trick and the `init (reverse ...)` hull construction need a moment of thought. The `cfg` case in `checkDynamicCollision` is clear enough. |
| design | 4 | Small reusable helpers (`cross`, `convexHull`, `minkowskiCloud`, `edges`) are shared between the two public functions, so there is no duplication. The configuration-space approach follows the spec. Weaknesses: `calculateCleanMinkowskiSum` is not reused in `checkDynamicCollision`, which calls `convexHull` and `minkowskiCloud` directly, so the zone-name and record wrapping are bypassed. The hull is also recomputed on every call. The motion check is split cleanly into containment plus edge intersection. |

**Overall:** The solution is pure and functional: a monotone-chain hull built as a fold, list comprehensions for the point cloud, and `any` over edges for intersection. Helpers are small and well named, and `Maybe` models absent polygons. Small blemishes are the partial `head`, `length` used for size checks, lazy `foldl`, and `checkDynamicCollision` not reusing `calculateCleanMinkowskiSum`.

**Anti-patterns:**
- partial `head` in `map head . groupBy`
- `length xs < 3` instead of pattern matching
- lazy `foldl` instead of `foldl'`
- `checkDynamicCollision` duplicates the hull construction instead of reusing `calculateCleanMinkowskiSum`

## Haskell test-2 (sample 1, attempt 0): mean 3.75

Code: [Haskell/test-2/sample-1/attempt-0/solution.hs](Haskell/test-2/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SE4aPyA5DRr2teSGpq`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and immutable. Dijkstra threads a Set-based priority queue plus Map state through a recursive `go` and relaxes edges with a fold, which is a sound functional shape. Small blemishes: the lazy `foldl` with a 3-tuple accumulator, a hand-rolled `fuel` counter in `reconstructPath`, and `addEdge` rebuilding the list with `splitAt` and `++`. A strict `foldl'`, a small record or State-free helper for the relax step, and a cleaner list update would earn a 5. |
| language | 4 | It uses `Data.Map.Strict`, `Data.Set`, `S.minView`, `M.findWithDefault`, guards and `where` correctly. Less idiomatic are `foldl` instead of `foldl'`, the `-1` sentinel for predecessors (forced by the contract), `drop t xs` pattern-matching in place of `!!` or a safe index, and `ds !! t` after bounds checks. `length ds` is recomputed. Silently ignoring invalid edges in `addEdge` is acceptable. Using `foldl'`, `Data.Array` or `Data.Sequence` for O(1) indexing, and `M.adjust` or `zipWith` for the update, would give a 5. |
| readability | 4 | Names are clear (`relax`, `go`, `initDist`, `adjM`). The nested `let` inside a guard branch in `go`, with a tuple accumulator, is dense. The fuel parameter in `reconstructPath` is not explained by a comment. Signatures are given on the local `go` functions. Extracting `relax` into a named top-level or where-bound function and adding a comment would improve it. |
| design | 3 | The decomposition is reasonable: public API functions, an `infinity` constant, and a local `go` in each of `dijkstra` and `reconstructPath`. Using `Set (Double, Int)` as the priority queue with lazy deletion is efficient. Weaknesses: `dijkstra` is one large function with the relaxation inlined, `addEdge` is O(n + deg) because of list append and `splitAt`, `getShortestDistance` and `reconstructPath` do list-indexed O(n) lookups, and the fuel guard against cycles is clumsy. Separating a `relaxEdges` helper and building a distance array for lookups would raise it. |

**Overall:** The solution is pure and uses Set as a priority queue with Map-based state, so the Dijkstra core is idiomatic Haskell. It loses points for the lazy `foldl` on a tuple accumulator, list-based indexing with `drop` and `!!`, and the awkward fuel parameter in `reconstructPath`. `addEdge` using `splitAt` and `++` is workable but clumsy, and `dijkstra` inlines the relaxation logic instead of factoring it out.

**Anti-patterns:**
- lazy foldl with tuple accumulator instead of foldl'
- fuel counter to guard recursion
- O(n) list indexing via drop/!! for lookups
- list append (++ [Edge v w]) to add an edge

## Haskell test-3 (sample 1, attempt 3): mean 4.00

Code: [Haskell/test-3/sample-1/attempt-3/solution.hs](Haskell/test-3/sample-1/attempt-3/solution.hs) · tests: test_failures · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SE5C6ciFGX3VFvjmkt`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The build is a pure `foldl'` over `zip [0 ..] s` with an immutable `BState`, and `stepBuild` returns a new state by record update. Count propagation is a second fold over nodes sorted by `Down . nodeLen`, and children are derived afterwards with `IM.fromListWith`. There is no IO, IORef or State monad. Two things keep it from a 5: `findLink` is a hand-written local recursion that is partial in spirit (it relies on the roots terminating it), and the state-record threading is slightly imperative in flavour. |
| language | 4 | It uses `Data.IntMap.Strict`, `Data.Map.Strict`, `Data.Array`, `foldl'`, `comparing`/`Down`, record update syntax, list comprehensions and guards. Both `IM.!` and `arr !` are partial, but they are safe by construction. The `Maybe` handling follows the contract. `buildTree ""` makes `listArray (0,-1)` an empty array, which is fine. Imports are tidy. Minor blemishes are the `drop 2 (eertreeNodes t)` assumption and the `eertreeBuild Nothing 0` case, which the spec did not require. |
| readability | 4 | Names are clear (`stepBuild`, `findLink`, `propagate`, `childMap`, `finalNodes`). The `where` blocks are organised logically and the BState comment helps. `stepBuild` packs a lot into one `let` and `buildTree` has a long `where`, but both stay followable. Neither is split into smaller named helpers such as `addNode` or `propagateCounts`. |
| design | 4 | A separate internal `BState` keeps the build apart from the exported `Eertree`. Transitions live in a `Map (Int, Char)`, and the exported `nodeChildren` is derived once at the end. The build is O(n log n) rather than O(n), because of the sort and the Map, which is a minor departure. `eertreeCountOccurrences` scans the node list linearly, so it is O(nodes) rather than using a lookup. `buildTree` is a large function that could be split. The result is sound overall, with some duplication of `lenOf`/`linkOf` against the node accessors. |

**Overall:** The solution is a pure fold-based build over immutable `BState`, using IntMap/Map and `foldl'`, with propagation as a second sorted fold and children derived at the end. It reads well, with clear names and sensible helpers. It loses points for linear node scans in the queries, partial lookups, and a monolithic `buildTree`/`stepBuild`.

**Anti-patterns:**
- linear scan of node list for pattern lookup instead of a keyed structure
- buildTree is a large function with a long where block that could be split into helpers
- partial IM.! / array ! lookups relied on as invariants

## Haskell test-4 (sample 1, attempt 1): mean 3.75

Code: [Haskell/test-4/sample-1/attempt-1/solution.hs](Haskell/test-4/sample-1/attempt-1/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SEdy5Ei1SS87pYj1nH`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and immutable. `buildTable` uses `scanl step base items` to produce DP rows as a fold over the items, and `Data.Array` handles the lookups. Backtracking is a tail-recursive `go` with an accumulator that conses flags. It would earn a 5 if the backtrack were a fold or unfold (e.g. `foldr` over indices) and the array-of-arrays were replaced by a single 2D array or a lazy-array DP. |
| language | 4 | It uses `scanl`, `listArray`, list comprehensions, guards and `where`, and the `Result` record comes from the stub. Weaker points: `last rows ! cap` is partial, though safe here. The padding idiom `take n (values ++ repeat 0)` is a little hacky. `length weights` is duplicated. `if took then 1 else 0` and `f == 1` are manual flag handling. Negative weights are silently skipped with `w < 0 = prev`, which is ad hoc. A 2D `Array (Int,Int) Int` or `foldl'` with a strict step would be more idiomatic. |
| readability | 4 | The haddock comment on `buildTable` and the comment on the backtrack explain the intent. Names such as `step`, `base`, `took`, `tbl` and `itemArr` are clear and the functions are short. It loses a little because the `solve` where-block is dense, the `(tbl ! i) ! c` double indexing is noisy, and `c'` is terse. Pulling the backtrack step into a named helper would earn one more point. |
| design | 3 | Table construction is shared by `maxValue` and `solve`, which avoids duplication. The pure helper `buildTable` is separate and the DP is well factored. However, the padding of values and the zipping into `items` are duplicated in `maxValue` and `solve`. `solve` rebuilds an `Array` of rows and an item array from lists. `totalW` re-zips instead of being tracked during backtracking. A shared `prepare` helper and a 2D table would earn a 5. |

**Overall:** This is a clean, pure DP: `scanl` builds immutable `Array` rows and a tail-recursive `go` backtracks with an accumulator. The main weaknesses are the duplicated setup between `maxValue` and `solve`, the nested array-of-arrays indexing, and the manual flag handling, which together keep it from top marks. Overall it is idiomatic and readable with modest structural redundancy.

**Anti-patterns:**
- duplicated input-normalisation (`take n (values ++ repeat 0)`, `zip`) in both `maxValue` and `solve`
- array of arrays instead of a single 2D array
- magic 0/1 flag conversion via `if took then 1 else 0` and `f == 1`
- ad hoc silent handling of negative weights

## Haskell test-5 (sample 1, attempt 0): mean 4.00

Code: [Haskell/test-5/sample-1/attempt-0/solution.hs](Haskell/test-5/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SEg3bLfKyajo3jbd8y`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Pure functional throughout: the parser is a set of functions of type `String -> Maybe (a, String)` composed via the Maybe monad, and the evaluator uses `Either EvalStatus` with `mapM` to short-circuit. Operators are folded left by `binChain` through a recursive `loop`. A 5 would need a proper Parser newtype with Functor/Applicative/Monad/Alternative instances, which would remove the manual threading of the remaining string. |
| language | 4 | Uses `Maybe`/`Either` monads, `mapM`, `span`, `lookup`, `mod'`, guards and pattern matching on string literals in `binOp` and `callFn`. Weaknesses: the partial `tail str` in `parsePrimary` (safe only because of the preceding match), `read` for numbers, and an association-list rebuild in the `VariableNode` case with `lookup`. The `type Parser a = String -> Maybe (a, String)` alias is neat but a newtype with instances would be more idiomatic. |
| readability | 4 | Small, well-named functions (`binChain`, `parsePower`, `parseArgs`, `arityOk`, `powD`) that mirror the grammar one-to-one. Type signatures everywhere, and a helpful comment on `fmod`. Whitespace skipping is scattered and manual, which makes it slightly harder to confirm every place is covered. `parseIdent` also does the function-call logic, which is a little dense. |
| design | 4 | Clear separation of parsing, evaluation, binary operators and function dispatch. `binChain` removes duplication between the expr and term levels, and the arity table is data. Shortcomings: operators are Strings rather than an enumeration, as the contract forces, so `InvalidOp` fallbacks are needed. `callFn` repeats the arity checks the parser already did. There is no tokenizer stage, so whitespace handling is spread across the parsers. |

**Overall:** The solution is a clean, pure functional design: a Maybe-based recursive descent parser mirroring the grammar, with `binChain` abstracting left-associative chains, and an Either-based evaluator with `mapM` for short-circuiting. Minor departures include the hand-threaded `String -> Maybe (a, String)` instead of a monadic Parser type, the `tail` call, and `read` for numbers. Overall it is idiomatic and well-structured, but not at a 5.

**Anti-patterns:**
- partial function `tail` in parsePrimary
- `read` used to convert numeric strings
- hand-threaded parser state instead of a Parser newtype with Monad/Alternative instances
- scattered `skipWs` calls instead of a lexing stage

## Haskell test-6 (sample 1, attempt 0): mean 4.25

Code: [Haskell/test-6/sample-1/attempt-0/solution.hs](Haskell/test-6/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SEiwDv4pzMfWUQ8xCQ`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | The search is pure and declarative: `solutions` returns a lazy list of all completions, built with list comprehensions and `concat`. `solve` uses `take 1` and `countSolutions` uses `take limit`, so laziness provides the early cut-off with no mutable state or flags. The data flow is immutable, with `arr // [(i,d)]` producing new boards. A 5 would need a slightly more refined state, e.g. propagation or `concatMap`, but this is already close to ideal. |
| language | 4 | It uses `Data.Array`, list comprehensions, `minimumBy (comparing ...)`, `take`, and pattern matching on `case` with `[]`. Weaknesses: `candidates` uses `!!` on lists (acceptable given the precondition), and `candidates` and `candA` duplicate logic. `nub` and `elem` on lists are fine at size 9. `minimumBy (comparing (length . snd))` recomputes lengths, and the `[(i,cs) \| ... let cs = ...]` form is fine. `length g == 81` is checked first, and `&&` short-circuits before the array is built. The `peerTable` construction is O(81*81*27*9), but it is computed once as a CAF. `concat [..]` could be `concatMap`, a minor point. |
| readability | 4 | Names are clear (`units`, `peerTable`, `candA`, `solutions`, `unitOk`), and haddock comments are placed where they help. Functions are short and each does one thing. The `peersOf` comprehension with `any (\u -> i `elem` u && j `elem` u) units` is a little dense but understandable. A small shortcoming is that `candidates` and `candA` are near duplicates, which makes the reader compare them. |
| design | 4 | The decomposition is good: `units` and `peerTable` are shared by validation and candidate computation, and `solutions` is a single lazy generator reused by `solve` and `countSolutions`. Using `Array` for lookups is appropriate. The main flaw is the duplication between `candidates` (list-based, `!!`) and `candA` (array-based). `candidates` could be implemented by converting to an array and calling `candA`, or both could share a helper. The `peerTable` is precomputed, which is a sensible choice. There is also no dead-end short-circuit for zero candidates, although the MRV pick naturally yields an empty branch list. |

**Overall:** The solution is a pure, lazy-list-based backtracking search, where `take 1` and `take limit` give early termination without any imperative control. It shares `units` and `peerTable` between validation and candidate computation, and uses `Array` for lookup. The main blemishes are the near-duplicate `candidates` and `candA`, the `!!` indexing, and a few minor inefficiencies such as recomputing `length` in `minimumBy`.

**Anti-patterns:**
- duplicated candidate logic in `candidates` and `candA`
- `!!` indexing on lists in `candidates`

## Haskell test-7 (sample 1, attempt 0): mean 3.75

Code: [Haskell/test-7/sample-1/attempt-0/solution.hs](Haskell/test-7/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rt5c6TsEmud71pZcgz`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and uses lazy self-referential arrays (`mT`, `xT`, `yT` defined through `t`) for dynamic programming, which is the classic Haskell idiom. The traceback is a tail-recursive `walk` with accumulators, and no mutation is involved. It is not a 5 because the traceback re-derives the predecessor state by comparing values (`pst \| ... == v`) instead of storing back-pointers or using a combinator, and because it manually threads two accumulators. Those are small departures from the style. |
| language | 4 | It uses `Data.Array` with tuple indices, `listArray`, `array` with list comprehensions, guards, `where` and a `case` over an ADT. There are a few oddities. `negInf'` is a misleading name for `-mp` and is bound in a `where` inside a guard. There is a trailing space after the `if` expression. `maximum` over small lists is slightly wasteful. `10 ^ (15 :: Int)` is fine. Three separate `array` builds repeat the same comprehension. Lazy boxed arrays are acceptable here. A `bounds`-derived `n` and `m` is fine, but the `n`/`m`/`ca`/`cb`/`t` setup is duplicated. |
| readability | 3 | Names are short but explained: a comment documents the M/X/Y states, `endMAt` and `bestAt` are clear, and the cases are laid out cleanly. The `negInf'` binding is confusing, since it holds the mismatch penalty and is not infinity. Terse names such as `mv`, `xv`, `yv`, `ma`, `mp`, `go`, `ge` need the state comment to decode. The traceback logic is a bit dense, but it can be followed. |
| design | 4 | The split into `St`, `Tabs`, `buildTabs`, `bestAt` and `endMAt` is sensible, and the table construction is shared by the score and align functions. The duplication is in the setup in `alignmentScore` and `alignmentAlign`, which could be one helper. The treatment of cell (0,0) is handled through the `endMAt` special case, which is a little hacky. `tM` at the borders is `negInf` while `endMAt` patches (0,0). The traceback recomputes comparisons rather than storing pointers, which is acceptable but couples it tightly to the recurrence formulas. Using `negInf` with subtractions is safe at Int 64-bit. |

**Overall:** This is a clean lazy-array Gotoh implementation: pure, with an ADT for states and a tail-recursive traceback `walk`. The shared `buildTabs`, `bestAt` and `endMAt` keep the recurrences compact. The deductions are for the confusingly named `negInf'`, terse identifiers, duplicated setup in both entry points, and a traceback that recomputes equality comparisons instead of recording choices.

**Anti-patterns:**
- misleading name `negInf'` for the mismatch penalty
- duplicated setup (n, m, ca, cb, t) in both exported functions
- traceback re-derives predecessor state via value equality chains instead of storing back-pointers

## Haskell test-8 (sample 1, attempt 0): mean 3.75

Code: [Haskell/test-8/sample-1/attempt-0/solution.hs](Haskell/test-8/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rt6c7sFWC4c1ooMs1Q`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and declarative. It uses list comprehensions, `concatMap dfs` for preorder, lazy-array dynamic programming (`table = listArray ... [f m \| ...]`) for the matching, and a tail-recursive `go` with an explicit stack for Hierholzer, with no mutation. Some parts are naive: `eulerCircuit` threads `used` lists and rescans every edge on each step, and `mstEdgesA` recomputes keys from scratch. A 5 would need a cleaner data flow, such as an adjacency Map and incremental Prim keys. |
| language | 3 | It uses `Data.Array`, `Data.Bits` (`popCount`, `testBit`, `countTrailingZeros`), tuple `minimum` for tie-breaking, and `Maybe` for the empty input. Lookups on lists are inefficient and idiomatic containers are missing: `delete`, `notElem` and `nub` on lists where `Data.Set`/`Data.Map`/`IntSet` fit, which makes them O(n²) or worse. `inf = maxBound `div` 2` is a sentinel. `dAt pts` partial application and local type signatures are fine. `nub` for shortcutting is concise but quadratic. |
| readability | 4 | Small named helpers (`dist`, `mkArr`, `dAt`, `tourCostA`, `childrenOf`, `oddVertices`) carry short comments and signatures. The tuple-minimum trick in `mstEdgesA` is compact but dense. Naming like `go`, `f`, `w`, `cands` is acceptable. The Hierholzer stack/used-list logic needs some thought, and the `table` and `f` structure is readable. A 5 would have fewer dense one-liners and a comment on the tie-break reasoning. |
| design | 4 | Decomposition is good: shared `mstEdgesA`, `minMatching` (which returns both weight and pairs, reused by `matchingWeight` and `christofides`), `eulerCircuit` and `tourCostA` are all reusable. It avoids duplicating logic. Weaker points: edge multigraphs as lists of pairs with an O(E) adjacency scan, `used` as a list, and `oddVertices` computing the degree by scanning the whole edge list per vertex. Choosing Map/IntSet and precomputing adjacency would be better. `mstWeight` recomputes the tree. |

**Overall:** The solution is pure and declarative, with a lazy-array bitmask DP in `minMatching` and a clean pipeline in `christofides`, and sensible decomposition into shared helpers. It loses points because `eulerCircuit`, `oddVertices`, `mstEdgesA` and `nub` rely on quadratic list scans where `Data.Map`/`Set` structures would be idiomatic. Readability is good thanks to signatures and small functions, although the tuple-minimum and stack logic are dense.

**Anti-patterns:**
- list-based `delete`/`notElem`/`nub` where Set/IntSet fits
- adjacency recomputed by scanning the full edge list on every step
- list used as a visited-edge set in Hierholzer
- `inf` sentinel value instead of a Maybe or a smarter DP
- Prim recomputes keys from scratch each iteration

## Haskell test-9 (sample 1, attempt 0): mean 3.25

Code: [Haskell/test-9/sample-1/attempt-0/solution.hs](Haskell/test-9/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RtemtUvNcGNf4je8XV`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and persistent: the tree is rebuilt with `BNode` values, `foldl'` drives `insertAll` and `deleteAll`, and there is no mutable state. Remaining weaknesses: `setAt`/`take`/`drop` index surgery stands in for pattern matching or zipper-style splitting of children, and `!!` indexing is used heavily. Splitting lists with `splitAt` and pattern matching on the pieces would earn one more point. |
| language | 3 | Uses `foldl'`, guards, `where`, `span` and `takeWhile`, and returns `Maybe` for t < 2. But it leans on partial functions (`head`, `last`, `init`, `tail`, `!!`) in `maxKey`, `minKey`, `rotateRight`, `rotateLeft` and `splitChild`. It also uses `length . takeWhile` instead of `span` or `splitAt`, and `length` for counts. There are no signatures on the local `where` helpers (`rotateRight`, `mergeRight`, etc.), which is acceptable. Avoiding partial functions and using `splitAt` would earn one more point. |
| readability | 3 | Top-level helpers are well named (`countLess`, `insertSorted`, `splitChild`, `shrink`) and the CLRS cases are easy to map (`deleteInternal`, `deleteDescend`, `rotate*`, `merge*`). However, `deleteFrom` is long with deeply nested if/else chains in `deleteInternal`. The `(ks', cs', j)` triples and index arithmetic like `i - 1` and `i + 2` are fiddly. There are almost no comments. Flattening the nested if-chain into guards and returning a small record instead of a triple would help. |
| design | 3 | The decomposition is reasonable: separate `member`, `splitChild`, `insertNonFull`, `insertKey`, `deleteFrom` and `shrink`. Duplication remains: merge logic is repeated in `deleteInternal` (2c), `mergeRight` and `mergeLeft`, and the list-removal expression `take i ks ++ drop (i+1) ks` recurs. `splitChild` and `insertNonFull` take the node and index as separate arguments. `member` and `deleteFrom` repeatedly scan the same node. A shared `merge` helper and a `removeAt` helper would earn one more point. |

**Overall:** The solution is pure and persistent, with `foldl'` driving the operations and `Maybe` for invalid t, which fits the functional paradigm. However, it relies on `!!`, `head`, `last` and `init` and on index arithmetic with `take`/`drop`/`setAt`, which are non-idiomatic and fragile. `deleteFrom` is long and nested, and merge logic is duplicated between case 2c and `mergeRight`/`mergeLeft`, so structure and readability are middling.

**Anti-patterns:**
- partial functions (head, last, init, tail, !!) throughout
- index-based list surgery with take/drop/setAt instead of splitAt and pattern matching
- duplicated merge logic in deleteInternal and mergeRight/mergeLeft
- length . takeWhile instead of span/splitAt
- tuple of (keys, children, index) returned from rotate/merge helpers
- deeply nested if/else chain in deleteInternal instead of guards

## Haskell test-10 (sample 1, attempt 0): mean 3.50

Code: [Haskell/test-10/sample-1/attempt-0/solution.hs](Haskell/test-10/sample-1/attempt-0/solution.hs) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rt21JQLiKTBWtWFUP1`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and functional: medianOfMedians composes `lowerMedian . map lowerMedian . chunks5`, and selectKth uses a recursive `go` with an accumulator, filters for the stable partition, and `reverse acc` at the end. The monadic binary search in `search` and `ok` is a clean recursive formulation without mutable state. Small blemishes are the unreachable `Nothing` branch inside `go` and the explicit accumulator-and-reverse pattern. Both are fine but not perfectly tidy. A 5 would remove the impossible Nothing case, for instance with a non-partial helper. |
| language | 3 | It uses Maybe, guards, `where`, `splitAt`, `filter` and `sequence` with list comprehensions as conditional reads, which is clever but slightly unusual. It also uses `!!` and `maximum`/`minimum` on lists that are non-empty only by reasoning, and these are partial functions. There is dead code: `odd'` and `_unused = odd'` only silence a warning. The `case medianOfMedians cur of Nothing -> Nothing` branch is a code smell. Using `fromIntegral` on Int before dividing avoids overflow, which is good. A 5 would drop the dead code, the partial `maximum`/`minimum`, and the impossible branch. |
| readability | 3 | Names are mostly clear (`lowerMedian`, `chunks5`, `leftMax`, `ok`, `search`), and the comments explain the partition predicate. However, the nested if/else in `go` is a bit dense. The `_unused`/`odd'` leftovers confuse the reader, and the shadowed `i` in `sequence [... \| i > 0]` makes the list-comprehension guards cryptic. A 5 would need cleaner structure and no leftovers. |
| design | 4 | The decomposition is sensible: helper functions for median and chunking, and a binary search on the shorter source with a monotone predicate `ok`. Reads stay within the O(log) budget. `ok` reads two values per step and the final step reads up to 4 more, which is fine. Weak points: `go` computes `length cur` repeatedly, `lowerMedian` sorts, the leftover dead binding is poor design, and the final-phase code is not factored into a helper such as `leftMax`/`rightMin`. A 5 would factor these helpers and remove the leftover code. |

**Overall:** The solution is pure and functional, with a clear composition for medianOfMedians, a stable filter-based partition in selectKth, and a monadic recursive binary search for the two-source median. Dead code (`odd'`, `_unused`), an impossible `Nothing` branch and reliance on partial functions (`maximum`, `minimum`, `!!`) lower the language-idiomaticity and readability scores. The structure is otherwise sound, but the final read step could be factored into helpers.

**Anti-patterns:**
- dead code: `odd'` and `_unused` binding only to silence warnings
- unreachable `Nothing` branch from medianOfMedians inside `go`
- partial `maximum`/`minimum`/`!!` relying on implicit non-emptiness
- nested if/else chain instead of guards in `go`

## Java test-1 (sample 1, attempt 2): mean 3.50

Code: [Java/test-1/sample-1/attempt-2/solution.java](Java/test-1/sample-1/attempt-2/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SEm9Ri6ChTyiJgLoNo`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The class extends the abstract SpatialLogic and overrides the four required methods, with private static helpers (extractVertices, convexHull, cross, containsInclusive, segmentsIntersect). The contract's public-field data classes limit the object model, but the author added no domain types of their own. Geometry such as a hull, segment or configuration-space builder could have been modelled as small classes, and the helpers are static functions on a stateless class, so the code reads closer to procedural than to OO. That keeps it at 3. |
| language | 4 | The code uses List/ArrayList, Comparator.comparingDouble(...).thenComparingDouble(...), diamond operators, a private static final EPS, @Override and a final class. The weaker spots are the raw Point[] 2n buffer with Arrays.asList(...).subList in convexHull, which is a C-style monotone-chain port, and null/empty returns from the status-less contract. The index loops that copy hull points into result.vertices could be a stream or toArray. It is solid but not polished. |
| readability | 4 | Names are clear (extractVertices, containsInclusive, segmentsIntersect, orient, onSegment). Methods are short enough, except checkDynamicCollision, which mixes csp building, containment and the size 1/2/n cases. There are no comments explaining the Minkowski difference or the epsilon choices. cross and orient are identical, which confuses a reader. A few one-line ifs omit braces. |
| design | 3 | Responsibilities split into sensible helpers, and the hull is reused by both the sum and the collision check. Extracting vertices defensively into copies is good. Flaws: cross and orient duplicate each other, the sum/difference point-cloud code is duplicated, and the O(nm log nm) all-pairs product followed by a hull is simple but not an edge-merge. The collision check special-cases degenerate hulls inline, and the hull logic is not in a reusable class. |

**Overall:** The solution correctly extends SpatialLogic and uses Java collections and comparators reasonably, with clearly named private helpers. However, it is essentially procedural: a stateless class of static geometry functions, no added domain types, and duplicated primitives (cross vs orient, duplicated all-pairs loops). The monotone-chain hull uses a C-style array buffer, and checkDynamicCollision is a bit long with inline degenerate-case handling.

**Anti-patterns:**
- static utility helpers instead of domain objects (no hull/segment types)
- duplicate geometry primitives (cross and orient are identical)
- C-style raw Point[] buffer with manual index juggling in convexHull
- duplicated cartesian point-cloud loops for sum and difference

## Java test-2 (sample 1, attempt 0): mean 4.00

Code: [Java/test-2/sample-1/attempt-0/solution.java](Java/test-2/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFHLPAFeMD8yCvAo9V`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The solution extends the abstract contract and overrides every method. It has a private nested QueueEntry class and keeps the algorithm in the instance methods. Because the contract's Graph and PathResult have public fields and no behaviour, the logic necessarily sits in the impl. That is acceptable, though little real object modelling is possible. A 5 would need more encapsulation, e.g. dijkstra split into private helpers such as relax or initResult. |
| language | 4 | It uses PriorityQueue with a lambda comparator, ArrayDeque, Arrays.fill, Double.compare, @Override and a private static final nested class. Weaknesses: the comparator could be Comparator.comparingDouble(...), or QueueEntry could be a record. Path reconstruction copies Deque to List to int[] by hand, where a stream (mapToInt) or a direct loop would be tighter. `path.peekFirst() != result.source` compares an Integer with an int, which unboxes correctly but is subtle. addEdge throws IllegalArgumentException, which the task did not specify but is reasonable. |
| readability | 4 | The names are clear: QueueEntry, candidate, current, limit, steps. Dijkstra's loop is compact and reads well, with the stale-entry skip clearly placed. reconstructPath is longer, with a defensive steps/limit counter and several redundant checks (path.isEmpty, a null distances check) that add noise. There are no comments, but the code is mostly self-explanatory. |
| design | 4 | Responsibilities are separated sensibly: validation in addEdge, the algorithm in dijkstra, and bounds-safe accessors. The lazy-deletion priority queue gives the required complexity. The dijkstra method is a single block of moderate size and could be factored. reconstructPath has a convoluted flow: while(current != -1) with an inner break, then a re-check afterwards, and a double conversion from Deque to List to array. The cycle guard is over-defensive for a well-formed result. |

**Overall:** The solution correctly implements the abstract contract and uses standard collections (PriorityQueue, ArrayDeque, Arrays.fill) with a private nested QueueEntry. dijkstra is clean and uses lazy deletion. reconstructPath is clumsy, with a double conversion to an array, a defensive step counter and redundant checks. The code is idiomatic overall, with minor room for polish through helper extraction, Comparator.comparingDouble and simpler path building.

**Anti-patterns:**
- redundant Deque -> List -> int[] copying in reconstructPath
- over-defensive loop guard and redundant post-loop checks
- anonymous-style lambda comparator instead of Comparator.comparingDouble

## Java test-3 (sample 1, attempt 0): mean 3.50

Code: [Java/test-3/sample-1/attempt-0/solution.java](Java/test-3/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFJcn5U8ccSvkcS5nt`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The class extends the abstract contract with @Override and splits behaviour into private helpers (addCharacter, getLink, propagateCounts, isPalindrome, charIndex). All helpers are static and take the Eertree as a parameter, because the contract exposes public mutable fields and a stateless implementer. Encapsulation and polymorphism are therefore thin, and the code reads like procedural functions over a data struct. That is largely forced by the contract. A 5 would need logic placed on the tree or node, which the contract does not allow. |
| language | 3 | It uses Math.max/min, String.regionMatches, substring, and an IllegalArgumentException for invalid characters. Naming is camelCase, except the loop variable `L`. The counting sort with manual int[] arrays is a C-style transplant. `Arrays` is imported but never used. `while (true)` in getLink is acceptable because the sentinel root guarantees termination. Reassigning the parameter `s` is a small smell. For a 5, drop the unused import, avoid parameter reassignment, and make the sorting less manual. |
| readability | 4 | Method names are clear, methods are short, and the algorithm is easy to follow. The 'Counting sort of real nodes by len, descending' comment helps. Single-letter names (c, w, p, l, j) are terse but conventional for Eertree code. The propagateCounts counting sort with its freq/start/order arrays takes some effort to read. A 5 would give more descriptive names and a simpler propagation step. |
| design | 4 | The responsibilities are separated: building, link lookup, propagation, queries, and palindrome check. Counting sort gives O(n) ordering, as the task requires. eertreeCountOccurrences scans all nodes linearly instead of walking the children transitions, which is simple but O(n) per query. The static helpers are not stored on a richer model, because the contract fixes that. Null and edge handling are consistent. A 5 would walk the trie from the root for the lookup and tidy the unused import and the parameter reassignment. |

**Overall:** The solution decomposes the build into small private helpers (addCharacter, getLink, propagateCounts) and has clean null handling, so it is easy to read. It is procedural in spirit, since static functions manipulate the contract's public-field structs, and that is mostly forced by the contract. Minor blemishes are the unused Arrays import, the parameter reassignment, the manual counting-sort arrays, and the O(n) node scan in eertreeCountOccurrences.

**Anti-patterns:**
- static helper methods operating on a public-field data struct instead of behaviour on objects
- manual counting sort with parallel int arrays (C-style)
- unused import java.util.Arrays
- reassigning method parameter `s`
- linear scan over all nodes for occurrence lookup instead of trie traversal

## Java test-4 (sample 1, attempt 0): mean 4.00

Code: [Java/test-4/sample-1/attempt-0/solution.java](Java/test-4/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFLAJAaqgeLnWbjUjN`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The class extends the abstract Knapsack and overrides both methods, with a private validate helper and no mutable instance state. The core algorithms are procedural DP loops inside two large methods, which is natural for this task. A 5 would need more object decomposition, for example a private table-building helper or a reconstruction method, instead of everything inline. |
| language | 4 | Uses @Override, a final class, Objects.requireNonNull with messages, IllegalArgumentException, Math.max, and the 1D rolling-array optimisation in maxValue. It caches row references (prev, curr) and uses a `continue` guard. Small departures: the inconsistent candidate>best check versus Math.max, and indexed loops that are fine here. Nothing in it is truly non-idiomatic, so it is close to a 5. |
| readability | 4 | Names are clear (best, skip, take, remaining, candidate, dp). Structure is easy to follow and the validate helper keeps the entry points short. There are no comments explaining the reverse reconstruction trick (dp[i][r] != dp[i-1][r]). solve is a bit long because the table fill and backtracking are inline, so it falls just short of a 5. |
| design | 4 | The shared validation is extracted. maxValue uses the space-optimised 1D array while solve uses the full table needed for reconstruction, which is a sensible choice. The table-filling logic is duplicated across the two methods rather than factored out, and solve does not reuse a helper for table building or backtracking. Extracting private methods such as buildTable and reconstruct would earn a 5. |

**Overall:** A clean, correct-looking OOP implementation of the contract: final subclass, @Override, a private validate helper with Objects.requireNonNull and IllegalArgumentException. It uses a 1D DP in maxValue and a 2D table in solve with backtracking via dp[i][remaining] != dp[i-1][remaining]. The main shortfalls are the long solve method and the lack of extracted helpers for table building and reconstruction.

**Anti-patterns:**
- solve mixes table construction and backtracking in one long method
- DP transition logic duplicated between maxValue and solve

## Java test-5 (sample 1, attempt 0): mean 4.00

Code: [Java/test-5/sample-1/attempt-0/solution.java](Java/test-5/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFQFc6ANUwrFMqb3Mp`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The AST is polymorphic: an abstract Node with eval(), and NumberNode, VariableNode, UnaryNode, BinaryNode, CallNode each carry their own evaluation, so evaluate() just delegates. State is encapsulated in final fields. The loss of one point comes from BinaryNode and UnaryNode dispatching on a char op through a switch, and CallNode switching on a String name, instead of per-operator or per-function polymorphism (an enum with abstract apply, or lambdas). That would have earned a 5. |
| language | 4 | The code uses an enum Kind, List/ArrayList/Map generics, a private static final ParseException with stack trace disabled, and string switch. The static initializer block for FUNCTIONS could be Map.of, and the hand-rolled isDigit/isIdentStart could use Character methods. The varargs isOp(String...) is acceptable. Using char and String op codes where an enum would fit is a small departure. Overall solid, with minor non-modern choices. |
| readability | 4 | The recursive-descent methods parseExpression/parseTerm/parseUnary/parsePower/parsePrimary map one-to-one onto the grammar, and the names are clear. Tokenizer and parser are separate, and the helpers ok/error/checkedPow keep the code tidy. The tokenize method is a long if-else chain, and parsePrimary is somewhat dense. Few comments, though section separators help. |
| design | 4 | There is a clean split into tokenizer, Parser, and Node hierarchy. Node extends the contract's AstNode and is private, and evaluate() guards against foreign nodes. The FUNCTIONS arity table validates calls at parse time. Weaknesses: operator and function semantics are stringly/char-typed, with duplicate unreachable default branches returning INVALID_OP, and CallNode uses an array and indexes. A functional-interface or enum-based operator table would improve extensibility. |

**Overall:** The solution is a well-structured OO design with a recursive-descent parser mirroring the grammar and a polymorphic Node hierarchy whose eval methods propagate statuses. Encapsulation and separation of tokenizer, parser and AST are good. The main departures are switch-based operator and function dispatch inside BinaryNode, UnaryNode and CallNode, and char/String op codes where an enum or functional objects would be more idiomatic.

**Anti-patterns:**
- switch on char/String operator codes inside node classes instead of polymorphic operators or an enum
- magic char/String operator representation rather than an enum
- static initializer block populating a HashMap instead of Map.of
- hand-written character class helpers instead of Character methods

## Java test-6 (sample 1, attempt 0): mean 4.00

Code: [Java/test-6/sample-1/attempt-0/solution.java](Java/test-6/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFqPwYWnxjNJLLeLHy`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | State and behaviour are encapsulated in a private static nested class `Search` (masks, `apply`/`undo`, `dfs`) built per call, and the public methods delegate to it. The outer class is stateless, which is reasonable. The mask-based design is more algorithmic than object-oriented: there is no `Board` type, and `Search` exposes its `found` field directly. A small `Board` abstraction, or encapsulating `found` behind accessors, would earn a 5. |
| language | 4 | Uses `Arrays.copyOf`, `Integer.bitCount`, `Integer.numberOfTrailingZeros`, `@Override`, `final` fields, private constants and a Javadoc comment. The lowest-set-bit idiom `m & -m` is standard. Minor departures: `search.found` is read from the outer class, `run()` is a pointless wrapper around `dfs()`, and `candidates` does not null-check (allowed by the precondition). Otherwise very idiomatic. |
| readability | 4 | Names are clear (`rowMask`, `bestIdx`, `bestMask`, `apply`/`undo`, `boxOf`, `bitOf`). Methods are short, and `dfs` is the longest but linear and easy to follow. The `ALL_DIGITS` binary literal has a comment. The `dfs` return value is documented as 'true when the search should stop'. The magic `3` and `9` remain in places, and `dfs` mixes cell selection with branching; extracting `selectCell` would earn a 5. |
| design | 4 | Validation, candidates and search are separated. Bitmasks give efficient MRV, and the early stop is propagated through a boolean return. The input is copied, so it is never mutated. `solve` and `countSolutions` share `Search`. The weaknesses are that `candidates` and `isValid` duplicate the mask logic that `Search` also has, `dfs` combines cell selection with branching, and `found` and `firstSolution` are accessed directly from outside. |

**Overall:** The solution isolates the mutable backtracking state in a private nested `Search` class and keeps the public API stateless, using idiomatic bit tricks and `Arrays` utilities. It is clean and efficient, with clear naming and short methods. Small blemishes are the direct field access to `found`, the redundant `run()`, and no dedicated board abstraction or extracted cell-selection method.

**Anti-patterns:**
- outer class reads Search's `found` field directly instead of using an accessor
- trivial `run()` wrapper around `dfs()`
- mask-building logic duplicated between isValid, candidates and Search

## Java test-7 (sample 1, attempt 1): mean 3.25

Code: [Java/test-7/sample-1/attempt-1/solution.java](Java/test-7/sample-1/attempt-1/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RtnBNxKdGo3NepP8MW`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The solution has a private `State` enum, a `Tables` holder class and `final` class design, so some OO structure is present. However, the work is done by a static `fill` function and one very long `align` method with a state-machine switch. The traceback is not an object with behaviour. A 5 would encapsulate the DP and traceback in methods or classes, such as a `Traceback` helper or per-state transition methods. |
| language | 4 | It uses `enum`, `ArrayDeque<Character>` with generics, `Math.max`, `@Override`, and a `default` branch that throws `IllegalStateException`. It also uses a `long` NEG sentinel with `Long.MIN_VALUE / 4` to avoid overflow. Departures: `Deque<Character>` boxes chars where a `StringBuilder.append` followed by `reverse()` would be simpler, and the classic `switch` with `break` could be an arrow switch. The `Tables` constructor fills three arrays in a loop and exposes package-private fields. |
| readability | 3 | Names such as `fill`, `open`, `ext`, `GAP_IN_B` and `Tables` are clear, and the structure follows Gotoh's algorithm closely. `align` is long, at about 90 lines, with the traceback inlined in the switch. Locals like `len` and `v` are mildly terse, and there are no comments explaining the state semantics or the gap-in-a/gap-in-b convention. Pulling out helper methods for the transitions would earn a 5. |
| design | 3 | `fill` is shared by `alignmentScore` and `align`, which avoids duplicating the DP. The `Tables` holder groups the three matrices. Weaknesses: the transition formulas are duplicated between `fill` and the traceback, the final-state selection is repeated in `alignmentScore` and `align`, and the full tables are allocated even for score-only calls. The traceback is not factored out, and the `a.isEmpty() && b.isEmpty()` guards are redundant given the DP initialisation. |

**Overall:** The code correctly follows Gotoh's three-table approach and uses a `State` enum, a `Tables` holder, generics and a safe sentinel. Structurally it is mostly procedural: a static `fill` and a long `align` method with a switch-based traceback, with duplicated recurrence and final-state logic. It is fairly clean but could be decomposed into smaller methods and use simpler string-building.

**Anti-patterns:**
- monolithic align method with inlined traceback state machine
- static helper function carrying the core logic instead of object behaviour
- DP recurrence duplicated between fill and traceback
- boxed Character deques instead of StringBuilder with reverse
- full O(nm) tables allocated for score-only computation

## Java test-8 (sample 1, attempt 0): mean 4.00

Code: [Java/test-8/sample-1/attempt-0/solution.java](Java/test-8/sample-1/attempt-0/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RtoiuHtpNH33m9KRVs`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Behaviour is split into private nested classes with state and methods: SpanningTree (edges, adj, degree, preorder, oddDegreeVertices), MinMatching (solve, pairs, minCost) and EulerCircuit. The public methods just orchestrate them. A point is lost because EulerCircuit is a class with only a static method (a function holder), SpanningTree exposes package-private mutable fields (weight, edges), and the outer class keeps static helpers dist/tourCost instead of a Point or Graph abstraction. A 5 would model points and edges as small types and keep the nested classes' state encapsulated. |
| language | 4 | Uses generics without raw types, @Override, final nested classes, List/ArrayList, Collections.sort and reverse, IntStream.range(...).filter(...).toArray(), and Integer.numberOfTrailingZeros for the bitmask DP. Departures: the fully qualified java.util.stream.IntStream inline instead of an import, a List<Integer> used as the Euler stack instead of Deque/ArrayDeque, edges as int[] pairs, and a memo array with -1 sentinels. Using ArrayDeque and an import would earn a 5. |
| readability | 4 | Names are clear (SpanningTree, MinMatching, EulerCircuit, oddDegreeVertices, preorder, tourCost) and each method is short. Javadoc comments are brief and useful, e.g. 'Minimum cost to pair all vertices not contained in mask'. Weaker points are the `found` flag loop in pairs(), which is a little awkward, the long SpanningTree.of with its three inner loops, and the stack manipulation via get(size-1)/remove(size-1). Splitting Prim's steps into helpers would improve it. |
| design | 4 | Decomposition is good: MST construction is shared by all four public methods, matching reconstruction reuses the memoised DP, and Euler circuit and shortcutting are separate. Prim's tie-breaking is handled explicitly: the smallest-index parent comes from scanning u in ascending order, and the adjacency lists are sorted for the preorder. Weaknesses: SpanningTree.of recomputes distances with a repeated O(n) scan, and the SpanningTree is rebuilt in each method (acceptable). The shortcutting is inline in christofides rather than in its own method, and there is duplicated edge-index bookkeeping. Overall it is clean and appropriate for the task. |

**Overall:** The solution is well decomposed into SpanningTree, MinMatching and EulerCircuit nested classes, with the public methods orchestrating them and sharing the MST. It uses standard collections, generics and a streams call where natural, and handles the tie-breaking rules correctly through the ordered parent scan and sorted adjacency lists. Minor departures are the List-as-stack, int[] edges, the inline fully qualified stream import and the `found` flag loop in pairs().

**Anti-patterns:**
- List<Integer> used as a stack instead of Deque/ArrayDeque
- Edges represented as raw int[] pairs rather than a small type
- Fully qualified java.util.stream.IntStream inline instead of an import
- Static-only EulerCircuit class acting as a function holder
- Boolean `found` flag loop in MinMatching.pairs()

## Java test-9 (sample 1, attempt 2): mean 3.25

Code: [Java/test-9/sample-1/attempt-2/solution.java](Java/test-9/sample-1/attempt-2/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RuK9DP127zCzdxygAn`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The contract's Node is a passive data holder with public final lists, so the author could not put behaviour on it. They chose a class full of `private static` helpers (`insert`, `splitChild`, `deleteFrom`, `isLeaf`, `isFull`) that mutate Nodes from outside, and `t` is threaded through every call. This is procedural code on data structs. A 4 would need an encapsulating object, such as a private helper class holding `t` with instance methods for split, merge and rotate, or at least a clear internal abstraction. |
| language | 4 | The code uses `List`/`ArrayList`, `subList(...).clear()`, `addAll`, `@Override`, `final` on the class, and diamond generics. The Integer/int unboxing in `x.keys.get(i) == k` is safe because k is an int. `keys.remove(int)` is used correctly for index removal. Small departures: `while (true)` loops with early returns, and a hand-rolled linear `lowerBound` instead of `Collections.binarySearch`. Naming and formatting follow conventions. Handling of absence is correct per the contract (null for t < 2). |
| readability | 3 | Short helpers (`isLeaf`, `isFull`, `maxKey`, `minKey`, `splitChild`) are clear, and `insert` is easy to follow. `deleteFrom` is about 60 lines and mixes cases 1, 2a, 2b, 2c, 3a and 3b, with inline rotations and merges using nested `x.children.get(i - 1)` expressions. There are no comments mapping the code to the CLRS cases. Extracting `rotateRight`, `rotateLeft`, `mergeChildren` and `fixChild` would raise this to a 4. |
| design | 3 | The decomposition is reasonable: a separate membership check, `splitChild`, and `maxKey`/`minKey`. Root handling is placed correctly in `deleteAll` and `insert`. Weaknesses: `deleteFrom` is monolithic, the merge logic appears twice (2c and 3b, twice again within 3b) without a shared helper, `t` is passed everywhere instead of being held as state, and `contains` plus the descent walk the tree twice. There is no abstraction around the mutation of the node lists. |

**Overall:** The solution is correct in structure and uses the Java collections well (`subList().clear()`, `addAll`, index-based `remove`). It reads as procedural code, though: a pile of static helpers taking `t` and mutating contract Nodes, with no encapsulating class. The `deleteFrom` method packs all the deletion cases and the rotation and merge code into one long body without comments, which hurts readability and design.

**Anti-patterns:**
- static utility methods operating on passive Node data instead of an encapsulating object
- parameter `t` threaded through every helper instead of held as state
- monolithic deleteFrom handling all CLRS cases inline
- duplicated merge/rotate logic not extracted into helpers
- hand-rolled linear search instead of Collections.binarySearch

<details><summary>Reasoning summary</summary>

I'm evaluating the code's design. The static helpers operate on Node, which is fixed by contract with mutable public lists, so the procedural style is partly forced. Still, passing `t` through every method feels like a smell, and a helper class holding `t` as a field might be cleaner.

The next stretch is a checklist of small observations: the Integer-versus-int comparisons and removals all check out as fine. I also note the linear lookup is acceptable for a small branching factor, the membership check is repeated, and the long delete method could be split into a few smaller pieces with some duplicated merge logic pulled out. Overall I'd rate paradigm and design a 3, language a 4, and readability a 3.

</details>

## Java test-10 (sample 1, attempt 1): mean 3.00

Code: [Java/test-10/sample-1/attempt-1/solution.java](Java/test-10/sample-1/attempt-1/solution.java) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rti45ojUXMpZBW2nbp`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The class extends OrderStats and overrides the three abstract methods, but all logic sits inside those long methods. There are no private helpers or small objects, and state is local to each call. selectKth is a procedural while(true) loop with counters and manual arrays. A 4 would need helper methods (e.g. partition, lowerMedian) that give the OO design finer behavioural units. |
| language | 3 | It uses Arrays.copyOfRange, Arrays.sort, clone and Math.min/max, and it uses long arithmetic for the large indices. It also maintains a hand-managed pivotBuffer int[64] with manual doubling instead of a growable list or IntStream collection, which is C-style array juggling. Counting and filling passes build the partitions by hand, where a stream or list would be shorter. The `(int)` casts on long indices are fine. More idiomatic structures would earn another point. |
| readability | 3 | Names such as lessCount, equalCount, medians and half are clear, and the algorithm follows the spec step by step. selectKth and medianTwoSorted are long with many flags (hasALeft, hasARight), and there are no comments explaining the partition invariant or the `ok` predicate. The binary-search condition is somewhat opaque, with redundant branches (mid >= m, j <= 0). Extracting helpers and adding a brief comment would earn a 4. |
| design | 3 | Group-median calculation is inlined, and medianOfMedians is reused by selectKth, which is good. The three-way partition is inlined with two passes and duplicated `v < p` tests. The pivot buffer is manually resized. medianTwoSorted mixes swap logic, binary search and result computation in one method. The design is workable but not well decomposed. Private methods for partition, lower median and the partition search would improve it. |

**Overall:** The solution follows the spec and reuses medianOfMedians inside selectKth, and it handles large lengths safely with long arithmetic. However, the logic is crammed into three long methods, with a hand-rolled pivotBuffer and manual two-pass partition. The binary search in medianTwoSorted has several boolean flags and no explanatory comments, so decomposition into private helpers would be needed to reach a higher score.

**Anti-patterns:**
- manual growable int[] pivotBuffer with doubling instead of a List or other collection
- long monolithic methods with no private helpers
- while(true) loop with manual counting passes for partitioning
- a magic initial capacity of 64

## Pascal test-1 (sample 1, attempt 0): mean 4.00

Code: [Pascal/test-1/sample-1/attempt-0/solution.pas](Pascal/test-1/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFvr7fweRpQC7kfbcB`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The solution is structured procedural code: small helper routines (Cross, PointLess, ConvexHull, MinkowskiPoints, SegmentsIntersect, PointInConvex) with explicit data flow and plain loops. Const parameters are used deliberately and early Exit keeps control flow simple. For a 5 it would need to drop the hand-rolled quicksort and the redundant Result/Exit flags, but the paradigm fit is strong. |
| language | 4 | It uses SetLength, Copy, High, Min/Max from Math, Exit, dynamic arrays and {$mode objfpc}, and keeps helpers in the implementation section. Weak points: a hand-written QuickSortPoints where the RTL or a generic sort would do. free_polygon manually nils the dynamic array and string before Dispose, which is unnecessary because Dispose finalizes managed fields. `Result^.Vertices := nil` before SetLength is also redundant, and `Exit` is used where `Exit(value)` could have been. Naming mixes snake_case from the contract with PascalCase helpers, which is fine. |
| readability | 4 | Names are clear (ConvexHull, MinkowskiPoints, OnSegment, PointInConvex), functions are short, and the comments are useful and not excessive ('Configuration space obstacle: Obstacle (+) (-Robot)', 'Closed segment intersection test'). SegmentsIntersect has a dense boolean condition, and the monotone chain's T := K + 1 is a bit cryptic. Otherwise it reads easily. |
| design | 4 | The decomposition is good. MinkowskiPoints is shared between calculate_clean_minkowski_sum and check_dynamic_collision, and the CSpace reduction to segment-versus-polygon is sound. Memory ownership is documented (the layer owns its polygons). Weaknesses: the O(n*m) point cloud plus hull rather than an edge merge, an inconsistent GEOM_EPS (exact comparisons in the hull versus epsilon elsewhere), and the two-step create-then-overwrite Vertices in calculate_clean_minkowski_sum, which allocates an array and then replaces it. |

**Overall:** This is a clean structured-procedural solution that reuses MinkowskiPoints and ConvexHull (monotone chain) for both required operations, and the CSpace segment test in check_dynamic_collision is clearly expressed. It makes good use of Free Pascal facilities such as SetLength, Copy, High and Math.Min/Max. Small blemishes include the custom QuickSortPoints, the redundant nil/empty assignments in free_polygon, and the extra allocation in create_polygon followed by overwrite.

**Anti-patterns:**
- hand-rolled quicksort instead of an RTL or generic sort
- redundant manual clearing of managed fields before Dispose
- create_polygon allocates a vertex array that is immediately replaced in calculate_clean_minkowski_sum
- mixed exact and epsilon floating-point comparisons

## Pascal test-2 (sample 1, attempt 0): mean 4.00

Code: [Pascal/test-2/sample-1/attempt-0/solution.pas](Pascal/test-2/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SFwYHYpmKV7m8VbVbj`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural Pascal with small helpers (HeapPush, HeapPop), explicit loops, early Exit guards, and in-place mutation of the result record. Dijkstra uses a lazy-deletion binary heap plus a Visited array, which is the standard imperative approach. It would reach 5 with minor tidying: the heap sizing is slightly awkward, and the two-pass path reconstruction could be a single pass that reverses in place. |
| language | 4 | It uses SetLength, High, Length, Inc/Dec, Exit, Infinity from Math, `out` parameters, and New/Dispose with dynamic arrays. There are small departures: the redundant `Result := nil` before New in CreateGraph and the redundant loop setting Adjacency[I] := nil (SetLength already zero-initialises). Setting dynamic arrays to nil before Dispose is acceptable but unneeded, and the code uses `Exit` rather than `Exit(value)`. Comparing `= Infinity` is fine. Fixing these would earn a 5. |
| readability | 4 | Names are clear (HeapPush, HeapPop, Visited, Alt, TotalEdges), functions are short, and the control flow is easy to follow. There are no comments, and the single-letter variables in the heap code (I, P, L, R, M) are terse but conventional. A brief comment on the heap capacity bound and on the lazy-deletion approach would earn a 5. |
| design | 4 | The heap is cleanly separated as private implementation-section helpers, public functions validate their inputs, and the graph and result are freed consistently. The heap is preallocated at TotalEdges+1, which is a correct bound, with the cost of an extra pass over all edges. Appending one edge at a time via SetLength is O(deg) per add, and the swap code is duplicated between push and pop. A heap abstraction (record with size) and geometric growth would improve it. |

**Overall:** This is a clean procedural Dijkstra with a hand-written binary heap in private helpers, lazy deletion, and guard clauses with Exit. It uses the RTL appropriately (SetLength, High, Infinity, out parameter). Small blemishes are redundant nil assignments, the heap size travelling as a separate var parameter, one-at-a-time array growth, and the absence of comments.

**Anti-patterns:**
- redundant initialisation of dynamic array elements to nil after SetLength
- heap size passed as a separate var parameter instead of being bundled with the array in a record
- SetLength by one per added edge (linear growth)

## Pascal test-3 (sample 1, attempt 0): mean 3.25

Code: [Pascal/test-3/sample-1/attempt-0/solution.pas](Pascal/test-3/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SG22egr6tgB1xQeBRp`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural: a single pass builds the tree with while loops following suffix links, a counting sort by Len gives the propagation order, and the query functions are plain loops with early Exit. Data flow is explicit and the control structures are simple. EertreeBuild is long, though, and its stages (validation, init, construction, propagation) are not split into procedures. Extracting those stages would earn a 5. |
| language | 3 | Uses Result/Exit, New/Dispose, SetLength, FillChar, Move, Break and an AnsiString copy, all fine in Free Pascal. Weaknesses: the repeated T^.Nodes[...] chains are not simplified with a local pointer or `with`; `Cnt := Cnt + 1` is used where Inc would do; the local `maxIdx` is a misnomer for a Len bucket key; the `Capacity` field is set but unused; and the local `L` clashes in style with the other lowercase names. Nodes := nil in EertreeFree is redundant but harmless. Cleaning these up would earn a 5. |
| readability | 3 | The algorithm is recognisable, and EertreeCanExtend is a well-named helper. The comment on the counting sort helps. However, the nested T^.Nodes[T^.Nodes[v].SuffixLink].Cnt expressions are dense, the build routine has many single-letter variables (w, v, c, L, k), and `maxIdx` is misleadingly named. Local aliases such as a node pointer or index variables would earn a 5. |
| design | 3 | The helper EertreeCanExtend removes duplication of the bounds-and-compare check. Counting sort keeps propagation O(n). Input validation is done upfront. Weaknesses: the monolithic EertreeBuild; EertreeCountOccurrences scans every node linearly and compares strings instead of walking the tree or using a lookup; the counting-sort propagation could be its own procedure; and there is no helper for node creation. Splitting those out would raise the score. |

**Overall:** The solution is competent structured Pascal with correct use of Exit, SetLength, FillChar and Move, and a clean counting-sort propagation. EertreeCanExtend avoids duplication, but EertreeBuild is long and heavy with T^.Nodes[...] chains. EertreeCountOccurrences is an O(n·m) scan over every node rather than a targeted lookup, which weakens the design, and a few naming and style slips (maxIdx, Cnt := Cnt + 1) cost readability.

**Anti-patterns:**
- monolithic build function mixing validation, construction and propagation
- repeated T^.Nodes[...] indexing instead of local aliases
- linear scan over all nodes for occurrence lookup
- misleading variable name maxIdx
- Capacity field set but unused

## Pascal test-4 (sample 1, attempt 0): mean 3.50

Code: [Pascal/test-4/sample-1/attempt-0/solution.pas](Pascal/test-4/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SGS7VbSNnUPFRiXKra`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural style: a 1D rolling dp array in KnapsackMaxValue and a 2D table with backtracking in KnapsackSolve, using for/downto loops and early Exit. Control flow is clear and uses the right DP shape. One more point would need less ad-hoc state, such as dropping the redundant zero-fill loops and the double initialisation of res^ fields. |
| language | 3 | It uses Min from Math, SetLength with 2D dimensions, New/Dispose, Exit and Continue, and the free procedure handles nil. Weaknesses: SetLength already zero-fills, so the explicit `dp[j] := 0` and `Selected[i] := 0` loops are redundant. `SetLength(res^.Selected, 0)` followed by another SetLength is redundant. Result is assigned from `res` rather than directly. `Exit(value)` is not used. The `if ... then dp[j] := ...` could be written with Max. |
| readability | 4 | Names (dp, w, v, total, res) are short but conventional for DP. The functions are moderately sized and the backtracking is easy to follow. The single long condition in the table-fill loop packs four checks together, and there are no comments explaining the guard for invalid weights/values. Adding a brief comment and using Max would earn the extra point. |
| design | 3 | The code is split into the three required routines. The dp logic is duplicated in two forms: a 1D version for the value and a 2D version for the selection. This is partly justified by memory use but means invalid-input handling is written twice with slightly different forms. A local helper or reusing KnapsackSolve's table would avoid the duplication. The 2D table is O(n*C) memory, which is necessary for backtracking. FreeKnapsackResult is correct and handles nil. |

**Overall:** The solution is a correct-looking procedural DP with a rolling 1D array for the value and a 2D table with backtracking for the selection, and memory is handled properly through New/SetLength/Dispose. It is somewhat undermined by redundant initialisation (SetLength already zero-fills, Selected is set twice) and by not using Max or Exit(value). The two DP routines duplicate the item-validity guard and recurrence rather than sharing code, which lowers the design score slightly.

**Anti-patterns:**
- redundant manual zero-initialisation after SetLength
- duplicated DP logic and validity guards across two routines
- redundant double initialisation of res^.Selected
- long combined condition inside the inner loop

## Pascal test-5 (sample 1, attempt 3): mean 3.25

Code: [Pascal/test-5/sample-1/attempt-3/solution.pas](Pascal/test-5/sample-1/attempt-3/solution.pas) · tests: test_failures · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SGWALB22RqdNVhZTwn`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural recursive descent. ParseExpr, ParseTerm, ParseUnary, ParsePower and ParsePrimary map one-to-one onto the grammar, using while loops for left-associative levels. Evaluate recurses over the AST with a `case` on Kind and early-exit status propagation. Parser state sits in unit globals (GSrc, GPos), which is a common procedural shortcut but makes the parser non-reentrant. A parser record or object passed by var parameter would earn a 5. |
| language | 3 | Uses New/Dispose, SetLength, High, Exit, Val, Copy, `in` sets, `out` parameter in FindVar, Math's Min/Max/IsNan/IsInfinite, and forward declarations. Weaknesses: the unit header puts `{$mode objfpc}` before `unit`, which is acceptable; string-comparison chains (`if Op = '+' ... else if`) in ApplyBinary and function dispatch where `case` on a char or enum would be better; a hand-rolled PowerChecked with square-and-multiply instead of Math.Power; `Result.Value := X - Y*Int(X/Y)` instead of Math.FMod or a similar routine. The repeated `GPos <= Length(GSrc)` checks could be wrapped in a helper. |
| readability | 3 | Names are meaningful and the functions are short, except ParsePrimary, which is long with many locals and deep nesting. It handles numbers, identifiers, function calls and parentheses inline. Many repeated `if X = nil then FreeAst... Exit` blocks add noise. Evaluate's ankFunction branch is a little awkward: it dummy-initializes R and evaluates the second arg conditionally on child count. There are no comments, but the code is mostly self-explanatory. Splitting ParsePrimary into ParseNumber, ParseIdentOrCall and so on would earn a 5. |
| design | 3 | Decomposition is decent: NewNode, MakeBinary, MakeUnary, FreeArgs, FunctionArity, FindVar, PowerChecked and ApplyBinary are separate helpers kept in the implementation section. Memory handling is careful, freeing partial results on failure and handing Args ownership to the node. Weaknesses: global mutable parser state; ParsePrimary does too much; operator and function dispatch uses string compares rather than a case or table; PowerChecked reinvents Power; ankFunction evaluation evaluates children generically but dispatches by name in one block. |

**Overall:** The solution is a clean procedural recursive-descent parser whose routines mirror the grammar, with careful manual memory management and early-exit error propagation in Evaluate. It is held back by global parser state, an overlong ParsePrimary, and string if-chains for dispatch. PowerChecked and the manual `%` formula reinvent RTL facilities, which lowers language idiomaticity.

**Anti-patterns:**
- global mutable parser state (GSrc, GPos)
- long monolithic ParsePrimary with many responsibilities
- string-comparison if/else chains for operator and function dispatch instead of case
- reimplementing power and remainder instead of using Math routines
- repeated manual free-on-failure boilerplate

## Pascal test-6 (sample 1, attempt 0): mean 4.00

Code: [Pascal/test-6/sample-1/attempt-0/solution.pas](Pascal/test-6/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SGb32BAh4JC4irvUa2`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The structure is procedural: a recursive `Search(var B, Limit, var Count)` works in place on a working copy and undoes the move with `B[best] := 0`. Early `Exit` handles dead ends and the cutoff. Helpers are small and data flows through explicit parameters. A 5 would need a cleaner contract: `Search` leaves B either solved or restored, and that is only implicit. The solution also recomputes `UsedMask` for every empty cell on every call instead of keeping incremental row/col/box state. |
| language | 4 | It uses `Exit`, `Copy(Grid,0,81)`, `SetLength`, `Result`, `var` and `const` parameters, and `{$mode objfpc}`. Helpers stay in the implementation section. Bitmasks are used well in `SudokuIsValid` with fixed arrays. `PopCountMask` reinvents `PopCnt` from the RTL, and the identifier `free` shadows the `Free` method name, though that is legal. `SudokuCandidates` does not guard Row/Col range (acceptable since the precondition is given). It also builds a 9-element array and then shrinks it. The `Math` and `SysUtils` units are unused. |
| readability | 4 | Names are clear (`UsedMask`, `PopCountMask`, `bestFree`) and the doc comments on `UsedMask` and `Search` help. Functions are short. The magic constant `$3FE` and the `1 shl d` bit tricks are not explained. `Search` mixes cell selection and branching in one routine and is a bit long. The `Search` comment is slightly confusing because B holds the last found board only when the limit is reached. |
| design | 4 | Solve and count share one `Search` routine, and validity is checked once up front. Candidate computation is shared via `UsedMask`. `SudokuCandidates` and `Search` both depend on `UsedMask`, so there is no duplication. A cleaner design would split out an MRV cell selector (`PickCell`) and keep incremental masks for speed. Using `Search` with Limit 1 for solving is neat. `SudokuIsValid` duplicates the box/row/col logic rather than reusing `UsedMask`, which is reasonable here. |

**Overall:** This is a solid procedural solution: `Search` implements MRV backtracking with in-place mutation and undo, and both `SudokuSolve` and `SudokuCountSolutions` reuse it on a `Copy` of the grid. It uses Pascal idioms well (`Exit`, `Result`, `Copy`, `SetLength`, bitmasks). Small blemishes include the hand-rolled `PopCountMask`, the unexplained `$3FE`, the shadowing name `free`, and the non-incremental candidate recomputation.

**Anti-patterns:**
- reimplements population count instead of using RTL PopCnt
- recomputes full UsedMask for every empty cell on every recursion instead of incremental masks
- magic constant $3FE without a named constant
- unused units Math and SysUtils

## Pascal test-7 (sample 1, attempt 0): mean 3.75

Code: [Pascal/test-7/sample-1/attempt-0/solution.pas](Pascal/test-7/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RuRRzYDaPzCcUKegDg`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The structure is procedural: FillTables fills the three DP tables, AlignmentAlign does an explicit state-machine traceback with a while loop and case on st, and results are written into preallocated buffers. Data flow goes through var parameters and plain loops, as expected for imperative Pascal. It would reach 5 with named state constants or an enum in place of the magic 0/1/2 and with the shared logic factored out more cleanly. |
| language | 4 | It uses SetLength with 2D dynamic arrays, Copy, Dec, New/Dispose, a typed const NegInf, and case. Naming is reasonable. Several things hold it back: Math is imported but Max3 is hand-written, NegInf is a typed const instead of a plain const, and lowercase locals like n, m and ra clash stylistically with the PascalCase used elsewhere. AlignmentAlign has an unused variable pattern (v reused across states). `Exit` and an enum type for states are not used. Arrays are freed automatically, so there are no leaks. |
| readability | 3 | A comment explains the MM/XX/YY meaning, and the identifiers are mostly clear. The traceback uses integer literals 0/1/2 for states and a long case body, and `pos` counts backwards from n+m+1, which takes some effort to follow. Short names like s, v and st are only moderately descriptive. Named state constants and a smaller traceback would earn a 5. |
| design | 4 | FillTables is shared by AlignmentScore and AlignmentAlign, so there is no duplication of the DP. Max3 is a sensible helper kept in the implementation section. The weaknesses are that AlignmentScore allocates full O(nm) tables where two rows would do, the traceback is a single large procedure body, and the three tables are passed as separate var parameters instead of being grouped in a record. |

**Overall:** This is a clean procedural Gotoh implementation: FillTables is shared, the traceback uses a case-driven state machine, and result memory is handled with New and Dispose. Readability suffers from the magic state numbers 0/1/2, the terse names s, v and st, and the backward-counting pos. Small design points hold it back: the score-only path stores full tables, and the traceback is a single long block.

**Anti-patterns:**
- magic integers 0/1/2 for traceback states instead of an enumerated type
- hand-written Max3 although Math is already imported (MaxIntValue could be used)
- full O(nm) tables allocated even for score-only computation
- one long traceback procedure with a large case body

## Pascal test-8 (sample 1, attempt 0): mean 3.25

Code: [Pascal/test-8/sample-1/attempt-0/solution.pas](Pascal/test-8/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RuXmz6EwjZcje6HSP1`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural Pascal: PrimMst, MinMatching, Preorder and TourCost are separate procedures with explicit var/const parameters, and control flow uses for/while loops. Hierholzer is an iterative stack loop, which suits the paradigm. Weaknesses: TspChristofides is one long procedure with many local variables, and Preorder rescans all of par for every node. Splitting out the Euler circuit and the shortcut step would earn one more point. |
| language | 3 | It uses SetLength, Length, High, Exit, New/Dispose, dynamic arrays, const parameters and the TIntArray type from the unit. Weaknesses: results are assigned with the old `TspX := ...; Exit;` style instead of `Result`/`Exit(value)`. `odd` is a local variable name that shadows the RTL Odd function, which the task warned against. The 2D adjacency matrix is flattened into `adj[v*n+u]`, and the pick code is packed as `i*64+j`. The unused `total`, `mstw` and `Math` import are minor. Using `Exit(value)` and a proper 2D array or record would earn one more point. |
| readability | 3 | Names are mostly meaningful (PrimMst, MinMatching, Preorder, TourCost), with helpful brief comments on Prim, matching and the Hierholzer/shortcut steps. TspChristofides is about 100 lines with short variable names (E, sp, cl, tl, pos) and several inline phases. The odd-vertex computation is repeated verbatim. The `pick` encoding with `code div 64` is a bit opaque. Extracting named helpers for each phase would earn one more point. |
| design | 3 | PrimMst, MinMatching and TourCost are shared and the helpers are kept in the implementation section. However, the degree and odd-vertex collection is copy-pasted in TspMatchingWeight and TspChristofides, and the Euler circuit and shortcut are inlined rather than extracted. The O(n²) multiplicity matrix and the bitmask DP with a pick array for reconstruction are suitable for n <= 40. The dead fallback block that appends unvisited vertices is unnecessary. Extracting an OddVertices helper and an EulerCircuit routine would earn one more point. |

**Overall:** The solution is clear procedural Pascal with sensible helpers (PrimMst, MinMatching, TourCost, Preorder) and correct memory handling via New/Dispose and dynamic arrays. It loses points for the long TspChristofides body, the duplicated odd-vertex code, the shadowing `odd` name, the flattened matrix and packed pick encoding, and the old-style function-name assignment. Overall it is decent but has clear room for tidier decomposition and more modern idioms.

**Anti-patterns:**
- duplicated odd-degree vertex computation in two routines
- monolithic TspChristofides procedure with inlined phases
- variable named `odd` shadows RTL Odd function
- flattened 2D matrix indexing `adj[v*n+u]` instead of a 2D array
- magic-number encoding `i*64+j` for pick
- assignment to function name plus Exit instead of Result/Exit(value)
- unused variables (total in TspDoubleTree, mstw)
- unnecessary defensive fallback for unvisited vertices

## Pascal test-9 (sample 1, attempt 0): mean 3.25

Code: [Pascal/test-9/sample-1/attempt-0/solution.pas](Pascal/test-9/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RuwieVxWv2gBLAB61B`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code follows a structured procedural style: small mutating procedures such as SplitChild, InsertNonFull, DeleteFrom and FreeNode, with loops and clear control flow. InsertNonFull is iterative, which suits Pascal. DeleteFrom is a long procedure that mixes cases 1, 2, 3a and 3b inline; a 5 would extract those into RotateRight, RotateLeft and MergeChildren procedures. |
| language | 3 | It uses SetLength, Length, High, exit, New and Dispose correctly, and keeps helpers in the implementation section. It reinvents array insert, delete and append helpers by hand instead of using Insert/Delete/Move/Concat from the RTL (FPC has Insert and Delete for dynamic arrays). It also writes 'Result := x; exit;' instead of Exit(value). It keeps the awkward unused 'p: PBTreeNode' in NewNode. A hand-written LowerBound is fine. A 5 would use the RTL array routines and Exit(value). |
| readability | 3 | Names are meaningful (SplitChild, InsertNonFull, LowerBound, MaxKey, MinKey) and brief comments mark each case. DeleteFrom is about 90 lines with many locals (j, i, n, m, idx, y, z, c, lft, rgt, kp), and j and i are redundant aliases. Moving the rotate and merge cases into named procedures would improve it. |
| design | 3 | Helper separation is good: array utilities, Contains for the pre-check, BuildTree shared by both public routines, and FreeNode for recursion. Keys and Children get duplicated insert/delete/append helpers, and the merge logic appears three times (case 2c, 3b-right, 3b-left) with similar code. The root-shrink logic sits in BTreeDeleteAll. Extracting merge and rotate helpers would remove the duplication. |

**Overall:** The solution is a clean structured-procedural B-tree: iterative insertion, a Contains pre-check, shared BuildTree and recursive FreeNode with correct New/Dispose handling. Its weaknesses are the long DeleteFrom, which inlines rotations and three near-identical merges, and the hand-written array helpers that duplicate RTL routines. Extracting RotateLeft/RotateRight/Merge and using Exit(value) and RTL array routines would raise the scores.

**Anti-patterns:**
- monolithic DeleteFrom procedure with inline rotate/merge cases
- duplicated merge code in three places
- hand-rolled array insert/delete/append instead of RTL Insert/Delete/Concat
- Result := ...; exit instead of Exit(value)

## Pascal test-10 (sample 1, attempt 0): mean 3.75

Code: [Pascal/test-10/sample-1/attempt-0/solution.pas](Pascal/test-10/sample-1/attempt-0/solution.pas) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RuKrsKmdYD2qo4kB4Z`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is structured procedural Pascal: small helper procedures with var parameters, while/for loops, Exit and Break, and explicit counting before filling the L and G arrays. Control flow is clear and the data flow is simple. Two things keep it from a 5: the pivot trace grows by one SetLength per level, and the loop is `while True do ... Break` rather than a condition-driven loop. |
| language | 3 | It uses SetLength, Copy, High, New/Dispose, Exit and Int64 arithmetic, and it stores the sum in a Double before dividing, which is the RTL-aware choice. Weaknesses: the author hand-wrote insertion sort and heap sort instead of using an RTL sort. Locals `a` and `b` in InsertionSortInts are lowercase and fight the A/B naming convention. Naming is mixed (cnt, mCount, kk). `hasRight` is assigned but never read. `Math` is not needed. |
| readability | 4 | The functions are well named (InsertionSortInts, SiftDownInts, MedianTwoSorted) and the helpers are separated. The one invariant comment explains the index bound in the binary search. SelectKth is long, with a two-pass partition and nested if/else chains, and the single-letter or abbreviated names (nL, nE, iL, iG, kk) cost some clarity. The binary search for the median has no comment on the partition idea. |
| design | 4 | MedianOfMedians is reused inside SelectKth. Helpers live in the implementation section, and the pivot-trace semantics are implemented exactly. The memory handling is clean: New/Dispose, arrays set to nil, and ownership transferred with `Cur := L; L := nil`. The partition search on the shorter source keeps reads at O(log). Weaknesses: the hand-rolled heap sort for at most a few elements is overkill, the partition logic is inlined in SelectKth instead of extracted, and the leftMax/rightMin logic is repetitive.. |

**Overall:** This is solid structured procedural Pascal. It makes correct use of SetLength/Copy/New/Dispose, does Int64 index arithmetic, and avoids the Single-precision pitfall by going through a Double variable. The weak points are the hand-rolled sorts, the long SelectKth with inlined partitioning, the `while True`/Break loop, and some dead state (hasRight), so it lands slightly below ideal.

**Anti-patterns:**
- hand-written heap sort and insertion sort instead of a shared sort helper
- `while True do ... Break` loop
- unused variable hasRight assigned but never read
- pivot array grown by one element per iteration
- partition logic inlined in SelectKth, which makes it long

## Prolog test-1 (sample 1, attempt 3): mean 4.00

Code: [Prolog/test-1/sample-1/attempt-3/solution.pl](Prolog/test-1/sample-1/attempt-3/solution.pl) · tests: test_failures · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SGiLZuwbcF6KPzYeao`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is relational in style: pattern-matching clause heads for chain/3, neg_pts/2 and consec/2, findall/member to generate pairwise sums, \+ and forall for universal checks, and a disjunction under once/1 for the collision tests. Weaker points: push_pt/3 uses a cut after a guard to emulate if-else; create_polygon/3 uses a cut-based dispatch on is_list; convex_hull/2 builds the hull with the clumsy append(A0,[_],A) idiom for dropping the last element; and the odd if-then-else/disjunction in seg_intersect/4 is hard to follow. A fully declarative version would use a cleaner formulation (e.g. last/2 or an explicit drop-last predicate). |
| language | 4 | Uses standard library predicates well (maplist, findall, forall, sort/2 for dedup and ordering, append, reverse, length, is_list, once) and a sensible module export list. Naming is snake_case and arguments are documented in mode comments. Departures: polygon_data uses =.. to accept any compound, which is loose; velocity_data uses a cut; the first-clause cut in create_polygon is somewhat hacky; and the argument-order guessing in create_polygon is non-standard. reverse and append(A0,[_],A) could be replaced by library calls such as last/3 or append/2. |
| readability | 4 | Predicates are small and mostly named by what they do (orient, in_convex, edges_of, seg_intersect, on_seg, minkowski_hull). Comments explain the algorithms (monotone chain, configuration-space obstacle, mode docs). The convex_hull body with A, U, A0, U0, LS, RS is cryptic, and seg_intersect mixes an if-then-else with disjunction chains that needs careful reading. The dual-order create_polygon and polygon_data flexibility add some noise. |
| design | 4 | Decomposition is good: orient/4 is a shared geometry primitive reused for convexity checks, hull building, membership and segment intersection. minkowski_hull is reused by both public predicates, so the configuration-space approach is implemented once. Hull-of-pairwise-sums is simple and correct for convex inputs even if O(nm log). Weaknesses: the hull construction is duplicated across lower and upper chains instead of a single helper; the flexible input handling (polygon_data accepting arbitrary compounds, create_polygon swapping args) widens the interface unnecessarily; the degenerate-case handling of in_convex (needs 3 vertices) is partially patched by the edge-intersection fallback. |

**Overall:** The solution is largely declarative and well factored: orient/4 underpins convexity checks, monotone-chain hull, membership and segment intersection, and minkowski_hull/3 is shared by both public predicates. It uses library predicates (maplist, findall, forall, sort, once) properly. Minor blemishes are the cut-based push_pt/3, the clumsy drop-last via append in convex_hull/2, and the overly permissive input handling in create_polygon/3 and polygon_data/3.

**Anti-patterns:**
- cut after guard in push_pt/3 to emulate if-else
- append(A0,[_],A) idiom to drop the last element instead of a helper
- lenient argument-order guessing in create_polygon/3 using a cut
- polygon_data accepts arbitrary compounds via =..

## Prolog test-2 (sample 1, attempt 3): mean 4.00

Code: [Prolog/test-2/sample-1/attempt-3/solution.pl](Prolog/test-2/sample-1/attempt-3/solution.pl) · tests: test_failures · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SH5QawhKNRg6MihhSF`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Pure state-threading with no assert/retract. Uses foldl/4 over edges and neighbours, and a recursive run_dijkstra with immutable assoc and heap state. Weaknesses: run_dijkstra and relax are written as nested if-then-else blocks rather than clause-head dispatch, and the foldl state is packed in a Heap-Dist-Pred triple. The cut in dijkstra/3 is a red cut used as an if-else guard before the fallback `dijkstra(_,_,none)`. A 5 would use clause-head pattern matching and a cleaner state structure. |
| language | 4 | Uses library(assoc), library(heaps), foldl, numlist, nth0, list_to_assoc, assoc_to_values and findall appropriately. But the findall with member for building lists is clumsy where maplist or pairs_keys_values would do, and `V-(-1)` is awkward. Using `inf` as an atom requires `Old == inf` special cases instead of arithmetic with a sentinel. The `Old == inf ; NewD < Old` disjunction inside a condition is slightly awkward. Declarative modes are respected overall. |
| readability | 4 | Predicate names (init_dist_pred, build_adjacency, add_adj, relax, walk_back) are clear and each predicate is short. Nested if-then-else in run_dijkstra is a bit dense, and there are almost no comments beyond the header. A reader can still follow the algorithm easily. |
| design | 4 | Good decomposition: adjacency building, initialisation, main loop, relax step, and path reconstruction are separate. Using assoc for the adjacency map and heaps for the priority queue is a sound data-structure choice. Minor issues: init_dist_pred builds two assocs via findall, the redundant `use_module(library(lists))`, walk_back uses nth0 on lists (O(n) per step), and the final result converts assocs back to lists. get_shortest_distance and reconstruct_path are reasonable; reconstruct_path could loop on malformed predecessors but that is not a design concern here. |

**Overall:** The solution is functional-relational in style: no global state, foldl over edges, library heaps and assoc for Dijkstra with immutable threading. The main departures are the red cut and catch-all clause in dijkstra/3, the nested if-then-else in run_dijkstra/relax, and the triple-packed foldl accumulator. Decomposition into init_dist_pred, build_adjacency, relax and walk_back is clean and readable.

**Anti-patterns:**
- cut in dijkstra/3 used as if-else guard before catch-all fallback clause
- nested if-then-else chains in run_dijkstra instead of clause-head dispatch
- state packed in Heap-Dist-Pred triple for foldl
- findall+member used where maplist/pairs would be simpler

## Prolog test-3 (sample 1, attempt 0): mean 3.00

Code: [Prolog/test-3/sample-1/attempt-0/solution.pl](Prolog/test-3/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SHHTNcC2dL55oY7MPs`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | State is threaded explicitly (st(A,Size,Last)), with no assert/retract. The control flow is imperative, though: build/5 is an if-then-else loop on I >= N rather than clause-head matching, step/4 nests deep if-then-else, and find_suffix uses if-then-else instead of clause dispatch. The use of nth0 with a conditional, findall/member and keysort is declarative enough. A 4 would need head-matching recursion and flatter case analysis. |
| language | 3 | Uses library(assoc), sub_atom/5, memberchk, keysort, max_list, nth0 and assoc_to_values, which is good. Weaknesses: building via an assoc and then converting to a list, the redundant repeated get_assoc on Cur, the unusual `eertree_build(none,_,none) :- !` placed before guards, and the catch-all `eertree_count_occurrences(_,_,_,0)` after a cut. Children is a pair list, which the task allows. max_list over a findall would be better as aggregate_all(max(L), ...), and between/numlist could replace the manual counter. |
| readability | 3 | Predicate names (find_suffix, propagate_all, step) are clear and find_suffix has a doc comment. step/4 is long, with nested conditionals, a repeated get_assoc for Cur, and the single-letter variables CL, CK, CCh, CC, CE, which make it hard to follow. Little commentary explains the algorithm. Splitting step into smaller predicates (extend, add_node, link computation) would earn a 4. |
| design | 3 | Reasonable decomposition into build, step, find_suffix, propagate and the queries. Assoc gives O(log n) node access during the build, which is sensible, then it is flattened to the required list. Node updates are duplicated: the get_assoc/put_assoc pattern for incrementing a count or adding a child is repeated and should be helper predicates such as update_node. Propagation re-fetches nodes by key. count_occurrences does a linear scan, which is acceptable. drop_roots is slightly awkward. A 4 would need factored node-update helpers and a cleaner step.. |

**Overall:** The solution is pure state-threading with no assert and uses the assoc library well, but control flow in build/5, step/4 and find_suffix/6 is written with imperative-style if-then-else chains rather than clause dispatch. step/4 is long and repeats node read/modify/write code, and cryptic variable names (CL, CK, CCh) hurt readability. The decomposition is decent, and the library usage is mostly appropriate, yielding an average idiomatic result.

**Anti-patterns:**
- if-then-else counting loop in build/5 instead of clause-head recursion or numlist/foldl
- deeply nested if-then-else in step/4 instead of separate clauses
- duplicated get_assoc/put_assoc node-update boilerplate with no helper
- catch-all fallback clause after a cut for count_occurrences
- findall + max_list instead of aggregate_all(max(...))

## Prolog test-4 (sample 1, attempt 0): mean 3.25

Code: [Prolog/test-4/sample-1/attempt-0/solution.pl](Prolog/test-4/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SHKTg4pqiudRPrmNBT`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The DP is a pure fold over items (fold_items/4) that threads an immutable table through step/4 and combine/4, with no assert/retract and no global state. Clause heads pattern-match on lists. Weaknesses: the table is a list shifted by padding with `none` and append, which is an awkward functional encoding. Combine uses nested if-then-else, and knapsack_max_value runs the full solve with reconstruction. A 5 would use a clearer recurrence, such as tabling or recursion on (Index, Capacity), with a cleaner relational formulation. |
| language | 3 | Uses maplist(=(0)), length/2 as a generator, last/2, reverse/2, and append/3 with a partial list for taking a prefix. It does not use foldl/4 for fold_items, which reimplements it by hand. `maplist(=(none), Pad)` and `append(Shifted,_,Ext)` for prefix-taking are tricks that are legal but not common. The `S == none` sentinel in place of a proper absence representation is un-Prolog-like. `(N =:= 0 ; Cap =< 0) -> ...` is acceptable. Using foldl and a nth-based or pairs-based representation would score higher. There is no handling of W=0 (length(Pad,0) works) or of negative W (length throws). |
| readability | 3 | Predicates are small, and there are comments on the signatures and on step/4 describing the table layout. The shift-by-padding trick in step/4 takes effort to understand, and combine/4 has nested if-then-else with the none sentinel. The names best, RevSel, Shifted and Pad are reasonable. A short comment explaining the shift would earn the 4th point. |
| design | 3 | Decomposition is reasonable: fold_items, step, combine and sum_weights are separate, and reconstruction rides along in the table through reversed selection lists, so no backtracking array is needed. max_value delegates to solve, which avoids duplication. The cost is that O(Cap) lists carry selections, and the shift is done via append, which is wasteful. The sum_weights recursion is not tail-recursive, and it could have been computed with foldl or sum_list. Mixing the sentinel `none` in with best terms weakens the data model. |

**Overall:** The solution is a pure, assert-free DP that threads an immutable capacity table through fold_items/step/combine and reconstructs the selection by carrying reversed choices, which fits the logic paradigm reasonably. Idiomatic touches include maplist, last and length-as-generator. It loses points for reimplementing foldl, using the `none` sentinel with `==`, nested if-then-else in combine/4, and the obscure padding-and-append shift trick. Its structure is sensible but somewhat awkward and inefficient.

**Anti-patterns:**
- hand-written fold_items instead of foldl/4
- `none` sentinel atom mixed into data and tested with ==
- if-then-else chains in combine/4 instead of clause-head dispatch
- append-based list shifting to emulate array indexing
- non-tail-recursive sum_weights that could use a library predicate

## Prolog test-5 (sample 1, attempt 0): mean 3.75

Code: [Prolog/test-5/sample-1/attempt-0/solution.pl](Prolog/test-5/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SHWL2watLfPVWsYFAD`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The parser is a recursive-descent parser over token lists with an explicit remainder argument (parse_expr/parse_term/parse_unary/parse_power/parse_primary), which is the classic Prolog style, and the evaluator pattern-matches on AST constructors in clause heads. Departures: it uses explicit difference-list threading instead of DCG notation, leans on if-then-else and cuts (tokenizer, expr_rest, combine), and `binop/4` has a catch-all last clause with no cut, so it leaves choicepoints and gives spurious invalid_op alternatives on backtracking. Using DCGs (phrase/2) and clean first-argument indexing would earn a 5. |
| language | 3 | Uses code_type/2, memberchk, maplist, number_codes, float_class and 0'c character literals sensibly, and catch for arithmetic errors. However, tokenizing with hand-written take_digits/take_ident instead of DCG basics or char_type, and `between(0'0,0'9,C)` instead of code_type(C, digit), are less idiomatic. The `member(result(S,_),Rs), S \== ok` check inside a condition and the non-exclusive `binop` fallback are minor smells. `valid_call/2` as facts is nice. DCG with string_codes would give a 5. |
| readability | 4 | Names are clear (parse_term, expr_rest, take_ident, unary_apply, combine), and the section headers help. Predicates are short and the grammar is easy to map to the code. Few comments explain choices such as why `%` uses truncate or why float_class is checked. Some heads like `evaluate(binary_op(Op, L, Rt), Vars, R)` mix R and Rt confusingly. |
| design | 4 | There is a good separation between tokenizer, parser, validity table (valid_call), and evaluator, with shared `power/3` used by both `^` and pow and a `combine` for status propagation. Weaknesses: binary_op evaluates both sides before short-circuiting, which is acceptable but not lazy; `combine` and `binop` duplicate status handling; and the function-call path repeats the status propagation logic rather than sharing a helper with combine. The failure-driven tokenizer lacks an explicit error clause but fails naturally. A common status-propagation helper would raise it. |

**Overall:** The solution is a clean recursive-descent parser with pattern-matching evaluator, split into tokenizer, parser, and evaluator, with a shared power/3 predicate. It loses points for not using DCGs, hand-rolled digit/ident scanning, a non-exclusive `binop/4` fallback that leaves choicepoints, and some duplicated status-propagation code. Overall it is solid, readable Prolog with a few non-idiomatic stretches.

**Anti-patterns:**
- catch-all binop clause without cut leaves choicepoints and alternative invalid_op solutions on backtracking
- hand-threaded token lists instead of DCG notation
- cuts used to emulate if-else in tokenizer and combine
- duplicated status-propagation logic in function_call and combine

## Prolog test-6 (sample 1, attempt 0): mean 3.25

Code: [Prolog/test-6/sample-1/attempt-0/solution.pl](Prolog/test-6/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SHiqN5iqKb2MWtJaun`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The search is nondeterministic in `solve_one` (`member(D, Ds)` with backtracking, committed by `->` in `sudoku_solve`), and `count_sol` threads an accumulator. However, the board is a mutable compound updated with `duplicate_term` and `setarg/3`, and `mrv_` is an imperative scan with nested if-then-else carrying a running best. `count_sol/branch` is manual state passing rather than `aggregate_all(count)` or `findnsols/4`. `sudoku_is_valid` uses a negated generate-and-test, which is fine. A logic-style version would use list-based pure data, `nth0`/`foldl`, `findnsols` or `limit/2`, and pairs-keyed MRV selection (`min_member`) to earn a 4. |
| language | 3 | Uses `maplist`, `between`, `findall`, `memberchk`, `arg/3` and `=..` to build the board, with correct `is`/`=:=`. But it hand-rolls things the library provides (`min_member`, `findnsols`, `aggregate_all(count)`, `sumlist`, `nth0`). `setarg` on `duplicate_term` copies is un-Prolog-like, and `=..` with 81 args is clumsy. `sudoku_candidates` does not validate list length or `is_list`, so malformed input throws. `peer/2` has a comment that is muddled and mentions the I==J case confusingly. |
| readability | 4 | Predicate names are clear (`peer`, `cands`, `mrv`, `solve_one`, `count_sol`, `branch`), there are section headers and a header comment explaining the b/81 representation. `mrv_/4` has deeply nested if-then-else and `R0 = cell(_, D0)` unification inside a branch, which is hard to follow. The `peer` comment is confusing. Overall it is mostly readable. |
| design | 3 | Reasonable decomposition into validation, candidates, MRV, solve and count. `peer/2` is recomputed with `//` and `mod` on every call, and `cands/3` scans all 81 cells for each empty cell, so the per-node cost is high and there is no precomputed peer table. There is some duplication between `sudoku_is_valid` and `cands` in the peer scanning. There is no constraint propagation beyond MRV, and the copy-per-branch approach is costly. Using precomputed row/col/box unit lists would make it cleaner and faster. |

**Overall:** The solution has a sensible structure and correct MRV backtracking with `member/2` and an if-then-else commit, but it relies on a mutable `b/81` term with `setarg`/`duplicate_term` and imperative-style loops (`mrv_`, `branch`). It reinvents library functionality (`min_member`, `findnsols`) and recomputes peers by arithmetic across all 81 cells for each query. It is readable, but a more declarative, list-based design with precomputed units would be more idiomatic.

**Anti-patterns:**
- destructive setarg/3 on duplicate_term copies instead of pure data
- imperative scan loop in mrv_ with a running-best accumulator
- manual counting loop instead of findnsols/aggregate_all
- peer computed via arithmetic over all 81 cells instead of precomputed units
- sudoku_candidates does not validate input shape
- reimplementing min selection instead of using min_member

## Prolog test-7 (sample 1, attempt 0): mean 3.00

Code: [Prolog/test-7/sample-1/attempt-0/solution.pl](Prolog/test-7/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RvFf9MexBiLd1gTAtR`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Recursion over lists with accumulators (fill_rows/6, row_step/6, trace/11) and head pattern matching on the state (trace(m,...), trace(x,...), trace(y,...)) is in the logic style, and the final pair of atom_chars/2 calls is fine. Cuts in start_state/5 are acceptable. However, the if-then-else chains with =:= inside trace/11 and the max/2 expression chains are functional/imperative DP rather than relational. start_state/5 uses cuts to emulate if-else (red-ish). A 5 would need a cleaner use of clause indexing or a helper that picks the predecessor state, with less deterministic-cut flavor. |
| language | 3 | It uses library(assoc), atom_chars/2, last/2 and is with max, and the module header is correct. Weak points: neg_inf/1 is a predicate used as a constant, there is a dead and odd p(_,_,GO,GE) re-construction in row0_ recursion (passes p(_,_,GO,GE) with fresh singletons rather than the P argument), and a stray `</br>` at the end of the file is a syntax-level defect. rows_pairs builds a huge assoc keyed by I-J when the rows could be indexed with nth0 or the tables stored as arrays. A 5 requires removing these oddities and using the library more simply. |
| readability | 3 | The header comment explains the c(M,X,Y) states and the transitions. The trace/11 comment documents the arguments. Names such as fill_row, row_step, start_state are clear. But trace/11 has 11 arguments, nested if-then-else, short names (Mu, Xu, Ml, Yl, Md), and row_step uses a sliding window [PD,PU\|PRest] which is subtle. The row0_ clause is confusing because of the re-built p/4 term. More comments on the traceback logic and fewer parameters (bundling the table and parameters) would earn a 5. |
| design | 3 | The solution separates DP fill, table conversion and traceback, and shares fill/4 between score and align. Parameters are bundled in p/4. Drawbacks: the traceback re-derives predecessor states by recomputing scores instead of storing pointers, trace/11 threads too many arguments, the table is stored twice (list of rows and an assoc of all cells), which costs memory and is O(log n) lookups, and the same transition formulas are duplicated between fill and trace. alignment_score computes the whole table instead of two rows. A 5 would use a single table representation and a smaller traceback signature. |

**Overall:** The solution uses accumulator recursion, clause-head dispatch on the DP state and library(assoc), so it is broadly reasonable Prolog. It is let down by the arithmetic-heavy if-then-else traceback in trace/11, cuts in start_state/5, the redundant list-of-rows plus assoc representation, and sloppy details like the re-built p/4 in row0_ and the stray `</br>` line. The decomposition into fill, table access and traceback is sensible but the traceback signature is heavy and formulas are duplicated.

**Anti-patterns:**
- cuts in start_state/5 emulating if-else instead of clause conditions
- nested if-then-else chains with =:= for traceback decisions
- trace/11 with excessive argument threading
- redundant conversion of row lists into a large assoc
- neg_inf/1 predicate used as a constant
- stray </br> text at the end of the file

## Prolog test-8 (sample 1, attempt 0): mean 3.00

Code: [Prolog/test-8/sample-1/attempt-0/solution.pl](Prolog/test-8/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RvK3nc7KhcQC9NrHEX`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The code is relational in places: Prim runs by recursion with accumulators, `pre/pre_children` use difference lists, and the matching DP threads the assoc state explicitly with no assert. Against that, `mst/3` has overlapping clauses (the third relies on its `Pts = [_,_\|_]` guard), and `pick_min`, `upd_front` and `best_pair` are chains of if-then-else on comparisons. `hier` and `take_edge` also use if-then-else where head pattern matching would be more declarative. One point more would need cleaner clause-head dispatch, with min-selection and edge removal done via `select/3` or `foldl`. |
| language | 3 | Standard libraries are used: `assoc`, `maplist`, `exclude`, `selectchk`, `aggregate_all`, `numlist`, `nth0`, `findall`, `sort`. The `sum_edges` predicate has a red cut that is only correct because the clause order is fixed; `sum_list` over `maplist` would be better. `dist/4` uses `nth0` on every call, which is O(n) per lookup, and `bits_of` has a cut and is not tail-recursive. The `nth0` calls inside the DP, `odd_vertices` using an `aggregate_all` count per vertex, and `member` plus `=:=` for edge lookup all show list-based handling where better structures exist. `none` is handled with `==` checks inside the public predicates instead of via clause heads. |
| readability | 3 | Names are mostly meaningful (`pick_min`, `upd_front`, `odd_vertices`, `shortcut`, `min_match`) and the section comments help. Terms like `V-K-P` and `Cost-Pairs` are positional and a little cryptic. The 9-argument `best_pair` and the 6-argument `min_match` with threaded memo state are dense, and `hier` has no comment explaining what its stack means. |
| design | 3 | The decomposition is clear: MST, tree walk, cost, odd vertices, matching DP, Euler circuit and shortcut are separate predicates, and the `tour_cost` and `matching` helpers are reused by both public predicates. The matching DP is exact and memoised on bitmasks. Weaknesses are the repeated O(n) `nth0` distance lookups with no precomputed matrix or array, the Euler edge list that is scanned linearly, and the way `none` is handled separately in each public predicate. The `mst/3` clauses are not mutually exclusive, so a choicepoint may be left on `mst([_],...)`, which is relevant to the determinism requirement. |

**Overall:** The solution is a working, well-sectioned decomposition that uses assoc-based memoisation and accumulator recursion without assert. Several stretches are imperative-flavoured: if-then-else chains in `take_edge`, `upd_front` and `best_pair`, and the red cut in `sum_edges`. Positional `V-K-P` triples and the 9-argument `best_pair` hurt readability. The O(n) `nth0` distance lookups and the overlapping `mst/3` clauses also keep it from the higher scores.

**Anti-patterns:**
- red cut in sum_edges relying on clause order
- overlapping mst/3 clauses leaving choicepoints
- if-then-else chains instead of clause-head dispatch (take_edge, upd_front, pick_min)
- repeated nth0 index lookups instead of a precomputed distance structure
- manual recursion where sum_list/foldl would do
- many-argument state-threading predicates (best_pair/9)

## Prolog test-9 (sample 1, attempt 1): mean 3.25

Code: [Prolog/test-9/sample-1/attempt-1/solution.pl](Prolog/test-9/sample-1/attempt-1/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RvX4bUm8ixA4mJ1WAu`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | State is threaded through pure predicates and foldl/4 drives the insert and delete sequences; there is no assert/retract. Dispatch uses if-then-else inside single clauses (insert_key, ins_nonfull, del_internal, fix_child) rather than clause-head matching. The first clause of del/4 uses a red cut with select/3. In del/4 the clause order and the cut in clause 2 make leaf versus internal dispatch depend on ordering. Predicates are mostly deterministic and functional, but they follow an imperative 'compute indices, then replace_nth' style. Clause-head pattern matching on key position, and splitting the nodes into separate clauses, would earn one more point. |
| language | 4 | The code uses nth0/4 in both insert and delete modes, foldl/4, append/3, select/3, memberchk, last/2 and length/2 as generators. It reimplements a few things: count_less is a hand-written recursion, which is not tail-recursive, and replace_nth is a thin wrapper over nth0/4. Naming is conventional (snake_case) and the comments are in the expected form. One departure is rot_right, which uses append(LKs0,[LKm],LKs) to take the last element where last/2 or append would be more explicit. Overall it is solid SWI-Prolog. |
| readability | 3 | Predicates are small and named after CLRS operations (split_child, fix_child, rot_right, merge_left). Mode comments appear on some predicates but not all, and the index arithmetic (I1, I2, NI) is dense. del_internal and ins_nonfull are long, with nested if-then-else. The insert_key comment on the root split is missing; split_child is used with parent keys [] and children [R0], a trick that needs explanation. A decent comment block exists at the top. Splitting the long predicates and adding mode docs would improve it. |
| design | 3 | The decomposition is sensible: membership check, split, insertion into a non-full node, and deletion split into del, del_internal and fix_child, with four small rotation and merge helpers. split_child is shared by root and child splitting. Structural duplication remains: rot_left and rot_right, and merge_left and merge_right, are near-mirror copies, and the membership check is repeated at each level. Data are plain lists with nth0 index access (O(T) per node), which meets the complexity bound. A cleaner design would use list-splitting helpers or a view of the node as left/separator/right. |

**Overall:** The solution is pure, uses foldl/4 for the key sequences, and passes state explicitly with no assert. It is organised around the CLRS operations. However, much of the control flow is if-then-else inside single clauses, and the index-driven nth0/replace_nth style makes it feel imperative. A red cut orders the clauses of del/4, and the mirrored rotation and merge predicates duplicate logic, so it lands in the middle of the range.

**Anti-patterns:**
- if-then-else chains inside single clauses instead of clause-head pattern matching
- index-based access with nth0/replace_nth throughout, in an imperative style
- red cut in del/4 to separate leaf, key-present and descend cases
- hand-rolled count_less instead of a library predicate (partition or take_while style)
- near-duplicate mirrored predicates (rot_left/rot_right, merge_left/merge_right)

## Prolog test-10 (sample 1, attempt 0): mean 3.50

Code: [Prolog/test-10/sample-1/attempt-0/solution.pl](Prolog/test-10/sample-1/attempt-0/solution.pl) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rv4HHkoWrJuGi6Hx17`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Recursion with an accumulator (select_loop carries a reversed pivot list, kth threads the remaining ranges) and maplist/include are used well. But select_loop and kth are nested if-then-else chains inside a single clause, not clause-head pattern matching, so control flow reads imperatively. chunks5 and take use red cuts (`take(_, [], [], []) :- !.`) where length/append, or a clause with first-argument indexing, would be cleaner. A 4 would need multi-clause dispatch on the La=0, Lb=0 and K=0 cases and no red cuts. |
| language | 4 | The code uses msort/2, nth0/3, maplist/3, include/3, reverse/2 and `is` correctly, and returns `none` as the task specifies. Weaker points: `select_kth` has an unparenthesised `(K<0 ; K>=Len) -> ... ; ...` whose precedence is correct but hard to see; partition/4 or a single pass could replace the three include/3 traversals; and the hand-written take/4 reimplements what length/append/append/3 give. A 5 would drop the hand-rolled chunking and clarify the condition structure. |
| readability | 4 | Predicate names (chunks5, lower_median, select_loop, kth, lt_pivot) are clear, and the kth predicate has a mode/semantics comment. The module header comments are kept. The long nested if-then-else blocks in select_loop and kth, and the ambiguous top-level condition in select_kth, cost some clarity. Short helper predicates keep each piece small. |
| design | 3 | The decomposition is reasonable: separate chunking, median, selection loop and the kth-by-halving search, with median_of_medians reused inside select_loop. The kth search is a clean O(log) algorithm over (getter, offset, length) triples. Weaknesses: the even-total case runs kth twice, repeating reads and work instead of fetching both middle elements together; three include/3 passes recompute the partition; and the six-to-eight argument kth signature would benefit from a source/offset term. |

**Overall:** The solution follows the specified algorithms and uses library predicates (maplist, include, msort, nth0) and an accumulator-plus-reverse for the pivot trace. It loses points for hand-rolled take/4 and chunks5 with red cuts, and for expressing the main loops as big nested if-then-else blocks instead of pattern-matching clauses. The two kth calls for even totals duplicate work, and the three include passes over the same list could be one partition, so the design is sound but not polished.

**Anti-patterns:**
- red cuts in take/4 and chunks5 instead of declarative clauses or library predicates
- nested if-then-else chains in select_loop and kth instead of clause-head dispatch
- reimplementing list splitting (take/4) instead of using library predicates
- multiple traversals (three include/3 calls) for one partition
- two separate kth runs for the even-total median

<details><summary>Reasoning summary</summary>

I'm checking the `select_kth` clause, where the if-then-else has no outer parentheses. Reading it through, the body still parses as intended, so the logic is fine; it just reads awkwardly.

I'm going through the rest of the clauses now: the cuts in median_of_medians and chunks5 look harmless, and the kth recursion stays well under the step limit. The main critique is design rather than correctness, with the nested if-then-else and repeated kth calls standing out as more imperative than they need to be. Scores are coming out around 3 to 4 for paradigm and design, and 4 for language and readability.

</details>

## Scala test-1 (sample 1, attempt 2): mean 4.00

Code: [Scala/test-1/sample-1/attempt-2/solution.scala](Scala/test-1/sample-1/attempt-2/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJ17Pf63rTF5F22qim`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is functional: immutable Vectors and Lists, the monotone-chain hull built with `foldLeft(List.empty[Point])(pushHull)` where `pushHull` is a pure pattern-matching recursion, and no `var` or loops. The Minkowski sum is a for-comprehension over Option and Vectors. A 5 would need little more; the `insideConvex`/`edgesOf` index-modulo edge construction is slightly imperative in flavour, which holds this to a 4. |
| language | 4 | It uses Option for-comprehension with `=` bindings, `case class.copy`, `exists`, `forall`, tuple pattern matching in `{ case (a, b) => ... }`, and named arguments, all natural Scala. Minor points: `poly.indices.map(i => (poly(i), poly((i+1)%n))).toVector` could be `poly.zip(poly.tail :+ poly.head)`; `lower.reverse.init` is a bit cryptic. Overall a solid 4. |
| readability | 4 | Helper names (`cross`, `sign`, `onBox`, `segmentsIntersect`, `insideConvex`, `pushHull`, `convexHull`) are clear and each function is short. The `Eps` constant is named. There are no comments explaining the CSpace reduction (obstacle ⊕ −robot, ray from origin to velocity) or the hull stitching, which would help a reader. Hence 4. |
| design | 4 | Good decomposition: geometric primitives, hull, Minkowski sum, and collision reuse `calculateCleanMinkowskiSum` through reflection of the robot. Collision is correctly framed as segment-vs-CSpace-polygon, with the containment case handled separately. Weaknesses: the Minkowski sum computes the full O(nm) point cloud rather than merging edges (acceptable given the task's 'point cloud' wording), and the hull uses `<= 0` without Eps, mixing tolerance policies. Overall a 4. |

**Overall:** A clean, immutable, expression-oriented solution: the hull is a fold over a pure recursive `pushHull`, the sum is an Option/Vector for-comprehension, and collision reuses the Minkowski sum with the reflected robot. Small departures include index-based `edgesOf`, no explanatory comments for the CSpace trick, and inconsistent tolerance handling. Overall it is idiomatic with only minor polish needed.

**Anti-patterns:**
- edge construction via index/modulo arithmetic instead of zip with rotated vector
- inconsistent epsilon use (hull uses exact `<= 0`, others use Eps)

## Scala test-2 (sample 1, attempt 0): mean 4.25

Code: [Scala/test-2/sample-1/attempt-0/solution.scala](Scala/test-2/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJ5YYfz19VE4gKc6VF`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | Pure functional style throughout: immutable Vector/List/TreeSet, a @tailrec `loop` carrying (frontier, dist, pred) as state, foldLeft over edges, and Option.flatMap for absence. No vars or mutation. A 5 is plausible; a small departure is the nested tuple-threading state in the foldLeft, which a small case class could express more clearly, but nothing is imperative. |
| language | 4 | Uses Option.flatMap, pattern matching with guards (`case Some(r) if ...`), `item @ (d, u)` binder, `isPosInfinity`, `copy`, `updated`, `Vector.fill`. TreeSet[(Double, Int)] as an immutable priority queue is a reasonable stdlib choice, though it relies on implicit tuple ordering. `graph.adjacency(from) :+ Edge` appends to a List, which is O(n) (Scala idiom would prepend with `::`). Imports are placed inside the object, which is acceptable. Minor issues only. |
| readability | 4 | Clear names (frontier, dist, pred, candidate, walk, initDist), logically structured, and moderately sized. dijkstra is a somewhat long function with nested loop and fold plus a triple-tuple accumulator, which takes some effort to read. No comments, but the code is mostly self-explanatory. Extracting a relax step would earn a 5. |
| design | 4 | Public API matches the contract and the helpers (loop, walk) are local. Guards for bounds are repeated between getShortestDistance and reconstructPath, and dijkstra does everything in one block, with no extracted `relax` helper. Data structure choices are good (TreeSet frontier with lazy deletion check `d > dist(u)`). addEdge silently ignores invalid edges, which is a defensible choice. List append is a small inefficiency. Overall solid but not perfectly decomposed. |

**Overall:** The solution is purely functional: a @tailrec `loop` in dijkstra threads an immutable TreeSet frontier, distance and predecessor vectors, and `walk` in reconstructPath is also tail recursive with Option results. Scala features such as Option.flatMap, guarded pattern matches and `copy` are used naturally. Weaknesses are the O(n) `:+` append in addEdge, the tuple-based fold accumulator, and a somewhat monolithic dijkstra body that could factor out a relaxation step.

**Anti-patterns:**
- List append `:+` on adjacency list (O(n)) instead of prepending
- Triple-tuple state threaded through foldLeft instead of a small named type
- Duplicated bounds-check logic across accessor functions

## Scala test-3 (sample 1, attempt 0): mean 4.25

Code: [Scala/test-3/sample-1/attempt-0/solution.scala](Scala/test-3/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJDr7NGwqi63xv5CV1`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | The build is a pure `foldLeft` over indices with an immutable `BuildState`. `insert` returns a new state, `propagate` is a fold over `updated`, and the suffix-link walk is a `@tailrec` function. There are no vars and no mutation. A 5 would need a few small refinements: `propagate` could be built more directly, and the occurrence lookup is a linear scan where a tree walk would be more natural. |
| language | 4 | It uses `Option` pattern matching with guards, `@tailrec`, `copy`, `Vector.updated`, `sortBy`, `find`, and `map/getOrElse`. Guard cases in `eertreeBuild` and `eertreeCountOccurrences` are used well. Small departures: `(0 until n).foldLeft(0)(math.max)` could be `.map(...).max`, and `getOrElse` after `map` could be `fold`. `(2 until n).sortBy(i => -len)` is fine. The `s(i) - 'a'` index arithmetic is acceptable. The `eertreeBuild(None, n<=0)` case is handled. |
| readability | 4 | Names are clear (`findExtendable`, `insert`, `propagate`, `buildFrom`, `BuildState`) and the functions are short. The comment on `findExtendable` helps, but it mentions `start` while the parameter is `cur`. The node index 0 serving both as the 'no child' sentinel and as the odd root is slightly implicit, though this follows from the contract. The link computation in `insert` is a little dense. |
| design | 4 | Responsibilities are split into walking links, inserting, propagating, building, and the public API. `Roots` is shared as a constant. The `BuildState` private case class is a sensible choice. Weaknesses: `Vector.fill(EertreeAlpha)(0)` is duplicated across several sites, and there is no `emptyNode` helper. Occurrence lookup scans all nodes with substring comparisons, which is O(n·m) instead of walking the tree from the roots using the pattern. `eertreeCountDistinct` includes a redundant `math.max`. Node copying makes each insertion O(26) per update, which is acceptable.. |

**Overall:** The solution is a clean functional implementation: a `foldLeft` over an immutable `BuildState`, a `@tailrec` suffix-link walk, and propagation by fold. It uses `Option` matching with guards well. Minor flaws are the repeated empty-children construction, the linear-scan lookup in `eertreeCountOccurrences`, and a stale comment on `findExtendable`.

**Anti-patterns:**
- linear scan with substring comparison for occurrence lookup instead of walking the tree
- duplicated `Vector.fill(EertreeAlpha)(0)` construction instead of a helper
- index 0 doubles as the 'no child' sentinel (contract-driven)

## Scala test-4 (sample 1, attempt 0): mean 4.25

Code: [Scala/test-4/sample-1/attempt-0/solution.scala](Scala/test-4/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJUAawdS4ZdtMMHmGg`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | The DP table comes from a `foldLeft` over `weights.zip(values)`, with each row built by `Vector.tabulate` from the previous row. Backtracking is another `foldLeft` that threads `(acc, c)`. There is no `var`, no mutation and no `return`, and everything is an expression. A 5 is blocked by the use of `rows.last` and `dp(i)(c)` indexing, which is slightly index-oriented, and by the `(n to 1 by -1)` fold. It is still close to ideal. |
| language | 4 | The code uses `Vector.fill`, `Vector.tabulate`, `collect` with a pattern literal `case (1, w)`, and tuple destructuring in `case` blocks. The name `selectedRev` is misleading, because prepending while iterating from n down to 1 already gives the forward order. `math.max` is fine. The guard clause is repeated in `maxValue` and `solve`. There is no use of `Option` or `Either`, which this task does not need. |
| readability | 4 | Names are clear (`table`, `prev`, `next`, `dp`), and the two comments are useful and not excessive. The functions are short. `selectedRev` misleads, since the list is not reversed. The condition `dp(i)(c) != dp(i - 1)(c)` is also slightly cryptic and would benefit from a short note. Overall it is easy to follow. |
| design | 4 | A private `table` helper is shared by `maxValue` and `solve`, so the DP is not duplicated. `solve` separates table building, backtracking and the weight sum. Storing the full table is needed for reconstruction, but `maxValue` could use a rolling row to save memory. The early-return guard is duplicated. `totalWeight` is recomputed from the selection instead of being tracked in the fold, which is fine. The `case (1, w)` match works but is a bit cute. |

**Overall:** The solution is purely functional, with `foldLeft` building the DP table and recovering the selection from it, and it has no mutable state. `Vector.tabulate` and `collect` are used naturally, and the shared private `table` helper avoids duplication. Minor blemishes are the misleading `selectedRev` name, the repeated guard and the full table kept even for `maxValue`.

**Anti-patterns:**
- misleading name `selectedRev` (list is already in forward order)
- duplicated guard condition in `maxValue` and `solve`

## Scala test-5 (sample 1, attempt 0): mean 4.00

Code: [Scala/test-5/sample-1/attempt-0/solution.scala](Scala/test-5/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJbbohYYaehJPyLTuE`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Fully functional: immutable tokens and AST, tail-recursive tokenizer `go` with an accumulator, parsers as pure functions returning `Option[(AstNode, List[Token])]`, and no vars or mutation. The `leftAssoc` higher-order helper is a good functional abstraction. A 5 would also remove the manual status-checking `if` chains in `evaluate` and use a monadic style such as Either or for-comprehensions for short-circuiting. |
| language | 4 | Uses sealed traits, case classes, pattern matching with guards, `Option.flatMap`, `span`, `find`, and `arities.get(name).contains(...)`. It uses a type alias `Parsed`, and the `@tailrec` annotation is applied correctly. Minor departures: `operatorChars.indexOf(c) >= 0` instead of `contains`, a regex check on the number text, the odd `go(cs.tail, ...)` where `tail` is already bound, hand-written `isDigit`/`isIdentStart` instead of `Char.isDigit`, `r.status != Ok` comparisons instead of matching, and `Option.contains`, which needs Scala 2.11+. Operators are Strings and Chars, which the contract mandates. |
| readability | 4 | Names are clear (`parseUnary`, `parsePower`, `applyBinary`, `ok`/`fail`), functions are short, and the grammar maps directly to the parser functions. The structure is easy to follow. There are no comments, and the nested flatMap/case lambdas in `parsePrimary` are slightly dense. The nested if/else in `evaluate` for BinaryOp is a bit clunky. |
| design | 4 | Clean separation of tokenizer, parser, and evaluator, with the evaluation primitives split into `applyFunction`, `applyBinary`, and `power`. `leftAssoc` removes duplication between expr and term. The arity table is data-driven. Weaknesses: `evaluate` repeats the short-circuit propagation logic in three places instead of a helper like `flatMap` on EvalResult or an Either. The `applyFunction` fallback duplicates the arity knowledge that the parser already enforces. |

**Overall:** The solution is a pure, immutable functional parser with a tokenizer, `leftAssoc` higher-order helper, and Option-based error handling, and the evaluator is cleanly pattern matched. The main blemishes are the duplicated status propagation in `evaluate` (UnaryOp, BinaryOp, FunctionCall) and a few small library-usage choices such as `indexOf`, a regex, and custom digit tests. Overall it is idiomatic and well structured, just short of ideal.

**Anti-patterns:**
- repeated manual status-check if/else chains in evaluate instead of a combinator for short-circuiting
- hand-rolled character predicates and regex validation instead of standard Char methods

## Scala test-6 (sample 1, attempt 0): mean 4.00

Code: [Scala/test-6/sample-1/attempt-0/solution.scala](Scala/test-6/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJgN3kq3hy5xKfQY24`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | The code is pure and immutable: boards are Vector values, and `g.updated(idx, d)` creates new states for the search. Backtracking is expressed as recursion over `Option`, with `cands.iterator.map(...).collectFirst { case Some(s) => s }` giving lazy short-circuiting. `countSolutions` uses `foldLeft` with the remaining budget passed down. There are no vars or mutation. One point is lost for the awkward early-exit fold (`if (acc >= remaining) acc` still traverses the rest of the candidates) and because `mrv` recomputes candidates for every empty cell by scanning from scratch instead of threading propagation state. That is acceptable but not elegant. |
| language | 4 | The code uses `Option`, pattern matching on `Option[(Int, List[Int])]`, `collectFirst`, `minBy`, for-comprehension generators with `by`, and `unit.map(grid)` (a Vector used as a function). The private `units` val is precomputed. It is Scala 2.11 compatible. Small blemishes: the tuple `Option[(Int, List[Int])]` is less expressive than a small case class, `(0 until 81).iterator.filter.map.toList` mixes iterator and list needlessly, `flatMap` over `List(...)` allocates, and `candidates` ignores the precomputed `units`. |
| readability | 4 | Names are clear (`units`, `mrv`, `search`, `count`, `remaining`), the functions are short, and the comment above `mrv` explains the tri-state result. The `search` and `count` nested functions are easy to follow. It would reach 5 if the tuple result were named, or if the index arithmetic `(br + k / 3) * 9 + bc + k % 3` were not duplicated between `units` and `candidates`. |
| design | 4 | The decomposition is clean: `units`, `isValid`, `candidates`, a shared `mrv` used by both `solve` and `countSolutions`, and nested search functions. The validity check is done once at the entry point. Weaknesses: the box index arithmetic is duplicated, `candidates` does not reuse `units` or peers, `mrv` recomputes candidates for all empty cells at each node with no early exit when a cell has 0 or 1 candidates, and the search structure is duplicated across `solve` and `countSolutions` (though their results differ). A case class or ADT for the MRV result would improve clarity. |

**Overall:** The solution is pure and immutable, uses Option, pattern matching, collectFirst and foldLeft naturally, and shares an `mrv` helper between `solve` and `countSolutions`. Minor issues are the tuple-based MRV result, duplicated box index arithmetic with `candidates` not reusing `units`, and a fold that continues iterating after the limit instead of short-circuiting. Overall it is idiomatic and readable with small design refinements possible.

**Anti-patterns:**
- Option[(Int, List[Int])] tuple encoding three states instead of a small ADT
- duplicated box index arithmetic between units and candidates
- fold that keeps iterating after the limit is reached instead of short-circuiting

## Scala test-7 (sample 1, attempt 0): mean 3.50

Code: [Scala/test-7/sample-1/attempt-0/solution.scala](Scala/test-7/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rw7CgGZFmD9Z2NPwgE`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The traceback is a pure @tailrec function that builds an immutable List[(Char, Char)] by prepending, and the final result is assembled with map/mkString. The Tables case class bundles the DP state, and subst and the traceback are pure. The DP fill, however, is imperative: mutable 2D arrays updated in a nested for loop, with no fold or lazy formulation. This is local and typical of DP, but a 5 would need a more functional fill, such as row-wise folds producing immutable rows. |
| language | 4 | The code uses case classes, @tailrec, pattern matching on state, a private case class, Array.fill with two dimensions, and Scala 2.11-compatible syntax. State IDs are Int constants (MatchState = 0, ...) matched in a `match`. Matching against capitalized vals works as a stable identifier, but it is a pseudo-enum where a sealed trait with case objects would be more idiomatic. The final `case _` hides the GapInA case. `for (i <- 0 to n; j <- 0 to k)` is fine but not ideal for side effects. |
| readability | 4 | Names are clear (fill, trace, subst, open, startState) and comments explain the sentinel and the states. Functions are short and the structure is easy to follow. The traceback's three branches are repetitive, and the Int constants lose some self-documentation. The tie-breaking if/else chains for predecessors are compact but slightly dense. |
| design | 3 | Fill is separated from scoring and traceback, and alignmentScore reuses fill. The Tables case class is a sensible grouping. The sentinel NEG is guarded against overflow. Weaknesses: the best/startState computation is duplicated between alignmentScore and align, the three-way max is repeated many times without a helper, and states are Ints rather than an ADT. alignmentScore also allocates full tables, though that is acceptable. |

**Overall:** The traceback is a clean @tailrec function over an immutable list and the code is well named, but the DP fill uses mutable arrays in a for loop, which keeps it only partly functional. DP state is encoded with Int constants rather than a sealed ADT, and the three-way max and best-score computation are duplicated. Overall it is solid, readable Scala with moderate functional purity.

**Anti-patterns:**
- mutable 2D arrays filled in nested for loop with side effects
- Int constants as pseudo-enum instead of sealed trait/case objects
- repeated nested math.max for three-way max instead of a helper
- duplicated best-score computation in alignmentScore and align

## Scala test-8 (sample 1, attempt 0): mean 3.75

Code: [Scala/test-8/sample-1/attempt-0/solution.scala](Scala/test-8/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwAUdfc52dboZumuoT`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Most of the code is functional. `mstParents` uses a `@tailrec loop` with immutable `Vector` and `Map`. `doubleTree` builds the preorder with a recursive `pre` and `flatMap`. `oddVertices`, `mstWeight` and the shortcut are folds over immutable values. `matchingPairs` mutates a `HashMap` memo, which is defensible for DP. The Hierholzer step in `christofides` is a `while` loop with `Array` and `mutable.Stack` and a `ListBuffer`. It is local but imperative, and a tail-recursive version over an immutable adjacency structure would earn another point. The Prim tie-breaking relies on lexicographic tuple `.min`, which is neat. |
| language | 4 | The code uses tuple pattern matching in folds, `collect` with guards, `Option` for the empty input, `getOrElse`, `groupBy` and `@annotation.tailrec`. It stays within Scala 2.11. Minor departures: `tree.contains` on a Vector inside `filterNot` is O(n); `(0 until n).map {...}.toVector` mixes ranges and vectors; `mutable.Stack` is used; `acc._1` access sits next to tuple destructuring; `tour.length` is shadowed as `n` in `tourCost`. Overall it is natural Scala. |
| readability | 4 | Names such as `mstParents`, `oddVertices`, `matchingPairs`, `tourCost` and `adj` are clear, and short comments mark Prim, the matching DP and Hierholzer. The `val (_, v, u) = ... .min` Prim step is dense and relies on tuple ordering for the tie-breaks without a comment explaining it. `matchingPairs` has a nested fold with a memo match and returns a tuple of cost and list, which takes some effort to read. The `christofides` body is long and mixes graph construction, Euler circuit and shortcut, which hurts a little. |
| design | 3 | Shared helpers (`dist`, `mstParents`, `tourCost`, `oddVertices`, `matchingPairs`) are reused across the four public functions, so there is no duplication. The memoised bitmask DP returns both cost and pairs, so `matchingWeight` and `christofides` share it. Weaknesses: `christofides` is a monolith and the Euler circuit is not extracted into its own function; the adjacency construction is O(n·E); Prim is O(n^3) (harmless for n<=40); the parent map is converted to edge vectors ad hoc rather than through a small graph type. |

**Overall:** The solution is largely functional: Prim runs as a `@tailrec` loop over immutable collections, the DFS preorder is a recursive `flatMap`, and the shortcut is a `foldLeft` with a `Set`. The weakest part is the Hierholzer implementation in `christofides`, which uses `while` loops, mutable arrays and a stack, and which sits inside a long function instead of its own helper. Decomposition into shared helpers is good, and naming is clear, but the dense Prim step and the monolithic `christofides` keep the scores at 4 and 3.

**Anti-patterns:**
- imperative while loops with mutable Array/Stack/ListBuffer for Hierholzer instead of a tail-recursive version
- mutable HashMap memo in matchingPairs
- Euler circuit logic inlined in christofides rather than extracted into a helper
- tree.contains on a Vector inside the Prim loop (O(n) membership test)

## Scala test-9 (sample 1, attempt 0): mean 3.75

Code: [Scala/test-9/sample-1/attempt-0/solution.scala](Scala/test-9/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwJXKCt2hg1hSPc7j3`

| criterion | score | why |
|---|---|---|
| paradigm | 5 | Fully persistent and immutable: Node is rebuilt with copy/updated, there are no vars, and the operations are folded with foldLeft in insertAll and deleteAll. fix returns a tuple (newX, index) instead of mutating. Recursion is structural, and the depth is only O(log n), so @tailrec is not needed. It could reach a 5 with less index arithmetic, for example by using helper functions such as removeAt and replaceAt to express the transformations more declaratively. |
| language | 4 | Uses Option for t < 2, a case class, Vector combinators (count, take, drop, init, tail, +:, :+), and Scala 2.11-compatible syntax. Weaknesses: `keys.count(_ < k)` scans linearly where a binary search or `indexWhere` could be used. The take/drop splice idiom is repeated everywhere instead of small utilities. The tuple return from fix is fine. `sys.error` is not used. There is no pattern matching, although it is not strictly needed. |
| readability | 3 | Names are clear (splitChild, insertNonFull, fix, maxKey, shrink, isFull). The fix function is long, with four branches that each build several Nodes using dense index arithmetic such as `x.children.updated(i, merged).take(i + 1) ++ x.children.drop(i + 2)`. There is one helpful comment on fix, and delete is a long nested if/else. Extracting rotateRight, rotateLeft, and merge as separate named functions and adding removeAt/insertAt helpers would earn one more point. |
| design | 3 | Decomposition is sensible: membership check, insertion, splitting, fixing, delete, and root shrinking are each separate, and the public API is a thin fold. Deficiencies: the repeated take/drop splicing is not factored out. The merge logic is duplicated between fix and delete case 2c. The leaf checks `if (isLeaf(y)) Vector() else ...` are redundant, since take/drop on an empty vector gives empty anyway. fix mixes rotation and merging in one function. Overall the design is solid but has some duplication. |

**Overall:** The code is purely functional: immutable Nodes, copy/updated, foldLeft over inputs, and Option for invalid t. It follows the CLRS rules cleanly and keeps the helpers separate. However, `fix` and `delete` are dense with index arithmetic, the merge logic is duplicated, and repeated take/drop splicing could be factored into helpers, so readability and design are middling.

**Anti-patterns:**
- duplicated take/drop splicing instead of small helper functions (removeAt/insertAt)
- fix is a monolithic function combining rotations and merges
- merge logic duplicated between fix and delete case 2c
- redundant isLeaf checks when taking/dropping children
- linear count(_ < k) for child index lookup

## Scala test-10 (sample 1, attempt 0): mean 4.00

Code: [Scala/test-10/sample-1/attempt-0/solution.scala](Scala/test-10/sample-1/attempt-0/solution.scala) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1Rw3Ry6jsbHBJQhVJAM`

| criterion | score | why |
|---|---|---|
| paradigm | 4 | Parts A is written functionally: `lowerMedian` is a pure helper, `medianOfMedians` uses `grouped(5).map(lowerMedian)`, and `selectKth` uses an immutable `@tailrec loop(cur, kk, pivots)` with `filter`/`count` for the stable partition. Part B uses `var lo`/`var hi` with a `while` loop, which is local and justified for a binary search, but a tail-recursive helper would be more in the functional style. That would earn the 5. |
| language | 4 | Uses `Option`, `grouped`, `@annotation.tailrec`, and `Vector` combinators, all compatible with 2.11. Small departures: `medianOfMedians(cur).get` on an Option known to be non-empty, `cur.sorted.apply(kk)` instead of `cur.sorted(kk)`, and the `(a, b)` swap by tuple pattern is fine. The `Some(...)` branches at the end of `medianTwoSorted` could be a single `Some(if ... else ...)`. The `.get` and the `var` loop keep it at 4. |
| readability | 4 | Names are clear (`lowerMedian`, `maxLeft`, `minRight`, `leftA`/`rightB`), and there is a helpful comment on the binary search invariant. The `medianTwoSorted` body is a long block with nested local defs and sentinel handling, but still easy to follow. Splitting the partition search into a named function would earn a 5. |
| design | 4 | Good decomposition for Part A: shared `lowerMedian`, reuse of `medianOfMedians` in `selectKth`. Partition is stable and single-pass per filter (three traversals, minor inefficiency). `medianTwoSorted` puts the search, sentinel handling and mean computation in one function rather than separate helpers; it does use Long arithmetic and swaps to search the shorter source. Extracting the partition search and the result combination into private helpers would improve it. |

**Overall:** Part A is clean functional Scala: `grouped(5).map(lowerMedian)` and an immutable `@tailrec loop` with stable `filter` partitioning that reproduces the specified procedure. Part B is a correct-looking partition binary search with Long arithmetic but written with `var lo/hi` and a `while` loop, and everything lives in a single long function. Minor nits like `.get` and `.sorted.apply(kk)` keep it from a top score.

**Anti-patterns:**
- mutable var/while loop for binary search instead of tail recursion
- Option.get on a known non-empty result
- sentinel Long.MinValue/MaxValue instead of Option

## Smalltalk test-1 (sample 1, attempt 0): mean 3.75

Code: [Smalltalk/test-1/sample-1/attempt-0/solution.st](Smalltalk/test-1/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SJr9ffvtnLFsRSkuUy`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Work is decomposed into small private methods on a SpatialLogicImpl object (minkowskiHullOf:with:, convexHullOf:, segment:to:intersectsConvex:), and the code uses polymorphic Polygon/Point accessors. However, the geometry is procedural and stateless: there are no Segment or ConvexHull objects, and the helpers could be extensions on Point or Polygon. A 5 would put more behaviour into domain objects such as Polygon>>minkowskiSum: or a hull value object. |
| language | 4 | The code uses collect:, reject:, do:, reverseDo:, asSortedCollection:, between:and:, ifNil:, and:/or: with blocks, and ^ early returns, all in proper GNU Smalltalk bracket syntax. Departures: `1 to: n do:` with `\\ n + 1` index arithmetic (a defensible use, since the indices are needed), whileTrue: loops, a manual `isNil ifTrue:ifFalse:` where `ifNil:` is shorter, and a manual dedupe loop where `asSet` or `inject:into:` could be used. The expression `(poly1 zoneName ifNil: ['']) copy` parses as intended, but the keyword-message precedence is subtle. |
| readability | 4 | Selectors are intention-revealing (validVerticesOf:, pointInside:convex:, segment:to:intersects:to:), methods are short, and there are helpful comments for Andrew's monotone chain and the configuration-space idea. The convexHullOf: method is a bit dense, with nested block conditions. The repeated lower/upper chain building is harder to read than it needs to be, and the `orient:to:point:` selector is slightly awkward. |
| design | 4 | Concerns are well separated: validation, Minkowski sum, hull, orientation, point-in-polygon and segment intersection. The configuration-space approach is correct in design, using obstacle ⊕ (−robot) and testing the segment from the origin to the velocity. The lower and upper chain construction is duplicated and could be extracted into one block or method. The computation is O(n·m log), which is fine. Geometry helpers sit on the logic class instead of in domain classes, and the n<3 degenerate cases are handled only partially. |

**Overall:** The solution is a clean, decomposed implementation using Smalltalk collection protocols and block-based conditionals, with a correct monotone-chain hull and configuration-space collision test. It loses points for a procedural, helper-method style on a service object rather than richer domain objects, duplicated lower/upper chain code in convexHullOf:, and a few manual loops and nil checks where `ifNil:` or collection messages would be tidier.

**Anti-patterns:**
- duplicated lower/upper hull chain construction
- geometry helpers on the service class rather than in domain objects (Point/Polygon/Segment)
- manual nil check with isNil ifTrue:ifFalse: instead of ifNil:
- manual dedupe loop instead of a collection protocol

## Smalltalk test-2 (sample 1, attempt 3): mean 3.00

Code: [Smalltalk/test-2/sample-1/attempt-3/solution.st](Smalltalk/test-2/sample-1/attempt-3/solution.st) · tests: test_failures · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SK1j8URn7We98xxX4p`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The logic sits in a ShortestPath subclass and uses the provided Edge, DijkstraGraph and DijkstraResult objects with message passing, so it is OO in form. But dijkstra:source: is one long procedural method: a manual min-selection scan over `visited` and `distances` arrays inside a whileTrue: loop, with mutable `current` and `currentDist` temporaries. A 5 would extract helpers such as `nextUnvisitedVertex` and `relaxEdgesFrom:`, or use a priority queue (SortedCollection), and put vertex validation on the graph object. |
| language | 3 | The code uses `isNil ifTrue: [^nil]` early returns, `and:` with blocks, `Array new:withAll:`, `addFirst:` and `FloatD infinity`, all of which are valid GNU Smalltalk. Weaker points: `isNil ifTrue:` where `ifNil:` fits, `to:do:` with a manual scan instead of a collection protocol, `notNil` as the loop condition, and `Array new: n withAll: nil` where plain `Array new: n` would do. The `isInteger` checks are defensive and not very Smalltalk-like, and the `infinity` method wraps `FloatD infinity` instead of using `Float infinity` directly. |
| readability | 3 | Names are clear (`distances`, `predecessors`, `visited`, `current`) and the code is short. The whileTrue: receiver block mixes the scan with the loop condition, which makes it harder to follow. The `+ 1` and `- 1` index mapping is scattered through the code, and the repeated target-bounds check is not named. There are no comments. |
| design | 3 | The five required methods are implemented, and a small `infinity` helper is the only extra. Duplication remains: the bounds check on a vertex appears in addEdge:, dijkstra: and getShortestDistance:/reconstructPath:. The index conversion is not centralised, and the Dijkstra core is not decomposed. The O(V^2) scan is acceptable but unextracted. reconstructPath: checks that the first path vertex equals the source, which is a reasonable guard. |

**Overall:** The solution is correct in structure and uses the provided classes via message sends, but dijkstra:source: is a long procedural method with an inline linear scan and mutable temporaries. The duplicated bounds checks and the lack of helper methods such as `relaxEdgesFrom:` or `isValidVertex:` reduce the design score. Language use is acceptable, with early returns and block conditionals, but it relies on index loops and `isNil ifTrue:` where more idiomatic forms exist.

**Anti-patterns:**
- monolithic dijkstra:source: method with a manual min-scan inside a whileTrue: loop
- mutable current/currentDist temporaries used to emulate a priority queue
- bounds validation duplicated across methods instead of a helper
- unnecessary isInteger defensive checks
- visited tracked in a parallel boolean Array, not a Set or Bag

## Smalltalk test-3 (sample 1, attempt 0): mean 3.00

Code: [Smalltalk/test-3/sample-1/attempt-0/solution.st](Smalltalk/test-3/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SKDrdy7b7P1ecVW6Ra`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Domain objects are used (EertreeNode, Eertree) and the work is split into helper methods such as newNodeLen:link:endPos: and matchPattern:length:node:in:. However, eertreeBuild:length: is one long procedural method with mutable locals and the whole algorithm inline. Node behaviour such as the link-finding walk is not pushed onto the objects, and the contract's accessor-only classes encourage this. Extracting the 'find suffix with matching char' loop and a propagate-counts method would earn a 4. |
| language | 3 | Uses cascades with yourself, Dictionary, asSortedCollection:, detect:ifNone:, conform:, and max:. The suffix-walk loop is written as `[... ] whileFalse:` with an awkward condition-and-assignment block. Mixed 0-based p with p+1 and k+1 adjustments is clumsy. `0 to: len - 1 do:` and `3 to: tree size do:` with index access are used where `inject:into:` or collection iteration would be more idiomatic. Declaring temps inside the block is fine in GNU Smalltalk. Overall decent but with some index-based style. |
| readability | 3 | Names are mostly clear and comments are present. Short temp names (k, w, c, s) and the duplicated suffix-walk loop make the build method dense. The `[k := .... k >= 0 and: [...]] whileFalse:` idiom is hard to read at first glance. The helper methods are easy to follow. |
| design | 3 | The node factory and pattern matching helper are well separated. The suffix-walk loop is duplicated twice in the build method instead of being a helper like `findSuffixFor:at:char:`. Count propagation sorts the whole node array, which is O(n log n) rather than linear, though that is permitted by the spec. Occurrence lookup is a linear detect over all nodes. Defensive checks on `tree size isNil` are redundant. The structure is acceptable but could be factored better. |

**Overall:** The solution uses Smalltalk collection messages, cascades and small helpers like newNodeLen:link:endPos: and matchPattern:length:node:in:, so it is serviceable. But eertreeBuild:length: is a long procedural method with the suffix-walk logic duplicated and written as a tricky whileFalse: block with index arithmetic. Better factoring into helper methods and less index-driven iteration would raise the scores.

**Anti-patterns:**
- monolithic build method with inline algorithm
- duplicated suffix-walk loop
- index-based to:do: loops where collection protocols would do
- convoluted whileFalse: block with assignment inside the condition
- redundant nil checks on tree size

## Smalltalk test-4 (sample 1, attempt 0): mean 3.25

Code: [Smalltalk/test-4/sample-1/attempt-0/solution.st](Smalltalk/test-4/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SKL4SqhZqNVLAqKMoU`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Logic lives in a KnapsackImpl subclass of the contract's Knapsack, overriding the two required selectors, and the DP table is built by a separate helper message. The algorithm is still procedural: a table of Arrays, nested index loops and mutable temporaries, with no domain objects such as an item or a table object. A 4 would need a little more object decomposition, for example a table or item abstraction, or collection-style iteration for the traceback. |
| language | 3 | Uses `Array new:withAll:`, `to:do:` with block-local temporaries, `ifTrue:`, `or:` with a block, `^` early returns and the contract's class-side constructor. The `to:do:` loops are justified because indices are needed. Weak spots: the 1-based offset arithmetic (`capacity + 1`, `c - wi`, `wi < c`) is confusing, `max:` is replaced by a manual compare-and-assign, and the `(cur at: c) ~= (prev at: c)` condition is not parenthesised in a way that signals intent. Using `max:` and `Array new: withAll:` consistently would earn a 4. |
| readability | 3 | Selectors such as `buildTableWeights:values:capacity:` and temporaries such as `prev`, `cur` and `row` are clear enough. The `c` index with its +1 offset is the hard part, and `c` means different things in `solveWeights:` (a mutable column) and `buildTable` (a loop index). There are no comments explaining the offset or the traceback. Short methods and consistent layout help. |
| design | 4 | The table-building code is shared by both public methods, which avoids duplication. The traceback is a sound way to recover the selection. The duplicated empty/capacity guard in both public methods could be factored out. The helper is public rather than private, since there is no `<category: 'private'>`. The full 2D table is kept even though only the traceback needs it, which is fine. The `wi < c` condition is a subtle but correct 1-based check. |

**Overall:** The solution is a correct, structured DP: `buildTableWeights:values:capacity:` is shared, and `solveWeights:values:capacity:` recovers the selection by traceback. It is mostly procedural in style, using index loops and mutable temporaries, with few Smalltalk collection idioms such as `max:`. The `+1` offsets, the duplicated guard and the public helper keep it from scoring higher on idiom and readability.

**Anti-patterns:**
- procedural nested index loops with mutable accumulators in the DP
- manual compare-and-assign instead of `max:`
- duplicated guard clause in both public methods
- helper method not marked private
- 1-based offset arithmetic (`capacity + 1`) scattered through the code

## Smalltalk test-5 (sample 1, attempt 0): mean 3.25

Code: [Smalltalk/test-5/sample-1/attempt-0/solution.st](Smalltalk/test-5/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SKUkqMK7ubTqhQJaN5`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The recursive-descent parser is split into one small method per grammar rule (parseExpr, parseTerm, parseUnary, parsePower, parsePrimary), and the AST is built with message sends. But the evaluator is a procedural dispatch on kind symbols (`kind = #num ifTrue:` ... ) and on operator strings (`op = '+' ifTrue:`) rather than polymorphism over node classes or a dictionary of operation blocks. The parser and evaluator are also merged into one class with parser state in ivars, and `parseExpression:` creates a fresh instance of itself to parse. Using AstNode subclasses or a selector/block table would earn one more point. |
| language | 3 | It uses `detect:ifNone:`, `on:do:`, `and:`/`or:` with blocks, `between:and:`, `isSeparator`, `isDigit` and cascades with `yourself`, all correctly. Weaknesses: `^Error new signal:` is used for parse errors, `Dictionary new` is rebuilt on every `arityOf:` call, `AstNode new initKind:` is used instead of the `AstNode kind:` class constructor, and `^self parseError` is used as if it returned a value. `[parser parseAll] on: Error do:` also swallows every error, not just parse errors. `e return: nil` is fine. |
| readability | 4 | Method names are intention-revealing (parseNumber, parseIdentifier, okResult:, errorResult:, powerOf:to:) and methods are short, with section comments. The long if-chains in `applyBinary:to:and:` and `evalCall:vars:` are repetitive. `evalCall:` evaluates `y` conditionally with a nil temp, which is slightly awkward. The code is still easy to follow. |
| design | 3 | The separation into token-level helpers, node constructors and evaluation helpers is reasonable, and okResult:/errorResult: remove duplication. Mixing parser state and evaluator in one class is a smell, the arity table is rebuilt on each call, and evaluation by string and symbol comparisons is not extensible. The operator and function tables could be class-side dictionaries of blocks, and the parser could be its own class. |

**Overall:** The parser is a clean recursive descent with one small method per grammar rule and clear names. The evaluator, however, is procedural: `evalNode:vars:`, `applyBinary:to:and:` and `evalCall:vars:` dispatch with chains of `ifTrue:` on symbols and strings instead of polymorphism or a table of blocks. Smaller issues are that `arityOf:` builds a Dictionary on every call, that parsing and evaluation share a stateful class, and that the broad `on: Error do:` handler hides other failures.

**Anti-patterns:**
- evaluation by symbol/string if-chains instead of polymorphism or a dispatch table
- parser state and evaluator mixed in one class
- dictionary rebuilt on every arityOf: call
- catching all Error to signal parse failure
- bypassing the AstNode kind: constructor with new initKind:

## Smalltalk test-6 (sample 1, attempt 0): mean 3.50

Code: [Smalltalk/test-6/sample-1/attempt-0/solution.st](Smalltalk/test-6/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1SKfuoeQes7giPcY4vX`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The logic is split across small methods on SudokuImpl (peerIndicesOf:, candidatesFor:board:peers:, searchOn:board:peers:stop:) and uses a block as a stop-callback, which is a nice Smalltalk touch. However, the board and peers are passed around as raw Arrays instead of a domain object such as a Board/Grid class, so state and behaviour are not encapsulated. Wrapping the board, peer table and search in a collaborator object would earn a 5. |
| language | 4 | Uses collection protocols (do:, reject:, collect:, remove:ifAbsent:, between:and:), non-local ^ returns, and 1 to: 9 do:. The code is GNU Smalltalk bracket syntax with correct selectors. Minor departures: copying the board with an index loop instead of `grid copy`/`asArray copy`, `Array new: 9 withAll: false`, and `(1 to: 9) reject:` answers an Array, which is fine. Peers are recomputed per call in candidates:row:col: and isValid: (81 Set builds). `ifFalse: [^#()]` is slightly awkward. |
| readability | 4 | Selectors are intention-revealing and each method is short, with helpful comments on the first three helpers. The search method has a flat structure with early returns. The `stop:` block semantics (answering true at a complete board) are somewhat subtle, and in searchOn the nested ifTrue inside to:do: is a little dense. Variables like best/bestCands are clear enough. |
| design | 3 | Decomposition is reasonable: peers are computed once per solve and shared, and solve and countSolutions reuse a single search with a stop block, which avoids duplication. MRV is implemented as required, with early dead-end detection. Duplicated setup code (board copy and peers construction) appears in both solve: and countSolutions:limit:, and in solve: the board is mutated back to 0 only on failure. isValid: recomputes peers for each cell, which is wasteful. Extracting a `prepareBoard:` helper or a Board class would improve it. |

**Overall:** The solution is a clean, compact MRV backtracker with small intention-revealing helper methods, and the stop-block trick shares one search between solve: and countSolutions:limit:. It keeps state in raw Arrays rather than domain objects, duplicates the setup code in the two public search methods, and uses an index loop to copy the grid. Overall it is idiomatic Smalltalk with modest design weaknesses.

**Anti-patterns:**
- raw Arrays passed around instead of a board object
- duplicated copy-and-peers setup in solve: and countSolutions:limit:
- index-loop copy instead of `copy`
- peer indices recomputed per cell in isValid:

## Smalltalk test-7 (sample 1, attempt 0): mean 3.25

Code: [Smalltalk/test-7/sample-1/attempt-0/solution.st](Smalltalk/test-7/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwfBY5ABwKGUsbodXD`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The work is split across small helper messages (negInfinity, newTableRows:cols:, cellOf:i:j:, fillTablesFor:...) and the class subclasses the abstract SequenceAlignment properly. However, the DP state is raw Arrays of Arrays and the traceback is a procedural loop with symbol states (#M/#X/#Y) and nested ifTrue:ifFalse: chains. A state-object or a dedicated table/matrix class, or polymorphic state transitions, would earn another point. |
| language | 4 | It uses max:, ifTrue:ifFalse:, and:/or: with blocks, whileTrue:, addFirst: on an OrderedCollection, and String withAll:. Mostly fine. But it uses to:do: with index math, an `Array new:withAll:` call that re-sends negInfinity, and temporaries declared inside blocks. The cellOf:i:j: accessors with an i+1 offset are a bit awkward. Tuple access via `tables at: 1` is positional, and `state == #M` comparisons by symbol are acceptable. The traceback could use a `Dictionary` or `inject:into:`, so it's not a 5. |
| readability | 3 | Selector names are clear, comments describe the M/X/Y tables, and the fill method is comprehensible. The align: method is long, with deeply nested ifTrue:ifFalse: in the traceback and repeated state-transition logic that is hard to scan. Splitting it into traceback helper methods would improve this. |
| design | 3 | Table creation, cell access and filling are separated from scoring and alignment, and fill is shared by both public methods, which avoids duplication. But align: is a monolith that mixes picking the end state and traceback. The three tables are returned as an anonymous Array, and the traceback repeats the recurrences' logic (open/extend arithmetic) instead of reusing it. Extracting traceback steps or a small table class would improve it. |

**Overall:** The solution is a working Gotoh implementation with sensible helpers (fillTablesFor:..., cellOf:i:j:) shared by scoreOf: and align:. Collection and block protocols are used reasonably, but the traceback in align: is a long, nested, procedural state machine over symbols, and the tables are anonymous raw arrays. Extracting traceback steps or modelling the tables/states as objects would make it more idiomatic OO Smalltalk.

**Anti-patterns:**
- long procedural align: method with deeply nested ifTrue:ifFalse: state machine
- raw Array-of-Arrays tables returned as an anonymous Array and accessed with `at: 1/2/3`
- state encoded as symbols with manual traceback instead of objects/polymorphism
- traceback duplicates DP recurrence arithmetic

## Smalltalk test-8 (sample 1, attempt 0): mean 3.00

Code: [Smalltalk/test-8/sample-1/attempt-0/solution.st](Smalltalk/test-8/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwuBuDgLWynzoERsH8`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The solution is a class with small helper methods (dist:to:, tourCost:points:, mstParentsOf:, preorderFrom:children:into:, oddVerticesOf:), and it uses the provided TspTourResult. The helpers are message sends to self, but there is no domain modelling. Graph, matching and Euler circuit are passed around as raw parallel Arrays (parent, key, inTree, ptr, used) and index arithmetic. The long christofides: method is a procedural Hierholzer inline. It would earn a 4 if the Euler circuit, matching and MST were separate objects or at least separate methods. |
| language | 3 | Uses inject:into:, collect:, select:, keysAndValuesDo:, Dictionary memo, bitAnd:/bitShift:, and ifNil-style tests. But index loops with to:do: appear where a collection protocol would work, and `bestV isNil or:` is used instead of detect:/inject. `(1 to: n) collect:` answers an Array, which is fine. Eleven temporaries are declared at the top of christofides:. Memo-based recursion is reasonable. `(mask bitAnd: ...) = 0 ifFalse:` is an awkward double negative where `anyMask:` or `allMask:` would be cleaner; lowestBitIndexOf: reimplements a loop. |
| readability | 3 | Method names are mostly meaningful, but the code is dense. The Prim loop is nested with long and:-chains. christofides: is about 45 lines with single-letter variables (v, w, k, e) and no comments. The 0-based bit index vs 1-based pts access (`i + 1`, `j + 1`) is confusing. The matching reconstruction duplicates matchCost:'s loop logic, which makes it harder to follow. |
| design | 3 | Decomposition is decent: MST parents are shared by all four public methods, and tourCost and preorder are reused. However, minimumMatchingOf: duplicates the search loop of matchCost:memo: (including the nearly identical best-selection with different nil checks). christofides: mixes multigraph construction, Hierholzer and shortcutting in one method that should be split into e.g. eulerCircuitFrom:edges: and shortcut:. Prim is O(n^2) with a redundant parent rescan, which is acceptable. The parallel-array data structures are weak. |

**Overall:** The code decomposes into reasonable helper methods and uses collection messages such as inject:into:, select: and keysAndValuesDo:, with sound DP and Hierholzer logic. But it is largely procedural: parallel arrays, nested index loops, and a 45-line christofides: that does the Euler circuit inline. minimumMatchingOf: duplicates the matchCost recursion, and the bit/index offsets reduce clarity.

**Anti-patterns:**
- monolithic christofides: method with a long temporaries list and inline Hierholzer
- parallel arrays (key, inTree, parent, used, ptr) instead of small objects
- duplicated search loop in minimumMatchingOf: and matchCost:pts:memo:
- double-negative `= 0 ifFalse:` for bit tests
- index-based to:do: loops in Prim instead of collection protocols
- mixed 0-based bit indices and 1-based array access (i + 1)

## Smalltalk test-9 (sample 1, attempt 2): mean 3.25

Code: [Smalltalk/test-9/sample-1/attempt-2/solution.st](Smalltalk/test-9/sample-1/attempt-2/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwyDk12gBEeUt6ePR2`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | Logic lives in a single BTreeImpl class that acts as a procedural algorithm container; BTreeNode is only used as a passive data holder, and every helper takes a node argument (splitChild:of:, mergeChildren:of:, fixChildAt:of:). It is not wholly procedural, since messages are sent to nodes and helpers are small. Placing split/merge/insert/delete behaviour as methods on BTreeNode (or a tree object holding t) would score higher, but the contract keeps the node class fixed, so this is partly forced. |
| language | 3 | Uses ifTrue:/and: blocks, whileTrue:, repeat, OrderedCollection protocol (addFirst:, removeLast, add:beforeIndex:), copyFrom:to:, early ^ returns. Non-idiomatic bits: dropAt:from: uses `remove:` of the element at index (removeIndex: exists), lowerBoundOf: is a hand-rolled linear scan (could use findFirst:), containsKey: uses `[...] repeat` with ^ exits, `^self` after procedural mutators, and t is passed through every method. Method categories are used only loosely (a comment string 'Helpers'). |
| readability | 4 | Selectors are intention-revealing (splitChild:of:degree:, fixChildAt:of:degree:, mergeChildren:of:), methods are short, and the docstring comments are helpful. fixChildAt: returns an index, which is a little implicit, and deleteKey:from:degree: is a long multi-branch method with several early returns. The two-letter temporaries (i, y, z) follow CLRS naming and are acceptable. |
| design | 3 | Good decomposition: membership, bounds, min/max, split, merge, rebalance, and insertion/deletion are separate methods; the membership check precedes any mutation as required. Weaknesses: `dropAt:from:` removes by value, which is fragile (the semantics of identity vs. equality for nodes, O(n) search); containsKey: duplicates the descent logic; t is threaded everywhere instead of being held in state; the tree is stateless so the insertion path and containsKey are done as two passes. The input collections are not modified. |

**Overall:** The solution is correct in structure and well split into small, named helpers (splitChild:of:degree:, mergeChildren:of:, fixChildAt:of:degree:), and it uses collection protocol and block control flow reasonably. However, all behaviour sits in the tree class acting on passive nodes with t passed everywhere, and several details are un-Smalltalk-like: remove: by value in dropAt:from:, manual while-loop scanning in lowerBoundOf:, and repeat with ^ in containsKey:. This yields a competent but middling idiomatic result.

**Anti-patterns:**
- node behaviour implemented externally in the tree class, with BTreeNode used as passive data (feature envy)
- dropAt:from: removes by value via remove: instead of removeIndex:
- hand-rolled index while-loop in lowerBoundOf: instead of findFirst:/detect
- degree t threaded through every helper instead of being stored as state
- `[... ] repeat` with non-local returns used for search loop

## Smalltalk test-10 (sample 1, attempt 0): mean 3.25

Code: [Smalltalk/test-10/sample-1/attempt-0/solution.st](Smalltalk/test-10/sample-1/attempt-0/solution.st) · tests: pass · judge: claude-sonnet-5-5 v2 · request `req_011Ch1RwdzbASpBS1o3ba7ce`

| criterion | score | why |
|---|---|---|
| paradigm | 3 | The work is spread over small methods on the OrderStatsImpl object (lowerMedianOf:, kthOf:in:and:, medianOf:and:), and the abstract class is overridden polymorphically. The algorithm bodies are still procedural: selectKth: keeps mutable cur/rank/pivots state in a `repeat` loop, and kthOf:in:and: does the same with offsets. There is no domain object such as a source wrapper or a partition result. A score of 5 would need a more object-centred decomposition, for example a partition helper or a source-view object. |
| language | 3 | The code uses select:, asSortedCollection, copyFrom:to:, min:, `^` early returns inside blocks, and `repeat` for loops. It also uses `1 to:by:do:` with block temporaries, which is reasonable here. Weak spots: OrderStats is redefined at the top of the file even though the contract already supplies it, and `asSortedCollection asArray` is a clumsy way to sort (`asArray sort` or `asSortedCollection` alone would do). There are three select: passes where a single pass or `count:` would be cleaner. Calling `^` inside a `repeat` block as the only exit is acceptable but a little awkward. |
| readability | 4 | Names are clear (lessPart, equalCount, greaterPart, remA, remB, offA, offB). Methods are short and the logic is easy to follow. There are no comments explaining the k-th search by halving k, which is the non-obvious part. Block-local temporaries are declared where they are used. |
| design | 3 | Part A and Part B are separated, and the helper kthOf:in:and: is reused for both the odd and even medians. The median computation duplicates lowerMedianOf: logic inside medianOfMedians: instead of calling the helper for each group. The redefinition of OrderStats in the solution file is a duplication of the contract. The even case does two full k-th searches, which is acceptable within the read budget but doubles the reads. The partition is done in three passes over cur. |

**Overall:** The solution is split into sensible helper methods and uses collection messages such as select: and copyFrom:to:. It still reads as procedural: selectKth: and kthOf:in:and: are mutable-state loops with `repeat`. The file also redefines OrderStats, which the contract already provides, and the lower-median logic is copied inline in medianOfMedians: rather than reusing lowerMedianOf:. Names are clear, so readability is good, but the code is only moderately idiomatic overall.

**Anti-patterns:**
- redefinition of the provided OrderStats abstract class in the solution file
- duplicated lower-median logic instead of reusing lowerMedianOf: for each group
- three separate select: passes where one would do (count: for the equal elements)
- asSortedCollection asArray used just to sort
- mutable-state loops with `repeat` and `^` as the only exit
