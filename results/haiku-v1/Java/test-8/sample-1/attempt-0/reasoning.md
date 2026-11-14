I'm setting up TspApproxImpl.java as a subclass of TspApprox, with the Manhattan distance and Prim's MST worked out first.

Still working out how to find each new vertex's parent, scanning the tree vertices at the moment it is added...

Still working through the cycle-cost and edge cases, covering n=1 and n=2. Next I'm settling how the matching weight is computed, using a bitmask DP over the odd-degree vertices.

Still working out the matching step: I'll have it return the actual pairs along with the weight, so the cycle can be rebuilt from the MST edges plus the matching edges, using a memo over the chosen partners.

Still writing the Euler tour: walking the multigraph with a stack, marking each edge used as I cross it, and popping finished vertices into a circuit.

Checking the Euler tour's output: the circuit comes out reversed but still starts and ends at 0, so the first occurrence of 0 sits at index 0 and the shortcut can follow list order. I'm also checking the edge cases here, where n=1 gives a single-vertex circuit and n=2 gives the two parallel edges 0-1-0.

Still writing the helper classes: edges as endpoint pairs, the degree counts, and the distance function, with the Euler walk using edge ids so each edge is used exactly once.

Still writing the spanning tree class, picking the next vertex by smallest key and then finding its parent among the tree vertices.

Still writing the spanning tree class: adding each new vertex with its parent chosen by scanning the tree in ascending order, then updating the keys from the new vertex's distances.

Still writing the spanning tree helpers: a DFS that collects vertices in order, with the adjacency lists sorted so children are visited in ascending index order. Then I'm computing the tour cost and handling the n=0 and n=1 cases directly for Christofides.

Still writing the matching class, using a memo over the unmatched odd vertices to find the minimum-cost pairing.

Still writing the matching memo: the recursion over remaining odd vertices, with the minimum cost stored per bitmask, then a pass that replays the choices to recover the actual pairs.

Still writing the matching helper: the bitmask recursion over the remaining odd vertices, plus the replay step that picks the actual pairs.


