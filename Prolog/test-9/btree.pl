:- module(btree, [
    btree_insert_all/3,
    btree_delete_all/4
]).

% CLRS B-tree with minimum degree T (T >= 2).
%
% Tree representation:
%   node(Keys, Children)
%     Keys     - proper list of integers in strictly ascending order
%     Children - [] for a leaf; otherwise a list of exactly length(Keys) + 1
%                node/2 terms
%   The empty tree is node([], []) (a root leaf without keys).
%   Every node holds at most 2T-1 keys, every non-root node at least T-1.
%
% btree_insert_all(+T, +Keys, -Tree)
%   Tree is obtained by inserting Keys one by one, in order, into the empty
%   tree with CLRS top-down insertion (pre-emptive splitting, median index T-1).
%   Keys already present are ignored (tree unchanged). Tree = none if T < 2.
%
% btree_delete_all(+T, +Keys, +Deletions, -Tree)
%   Builds the tree exactly like btree_insert_all(T, Keys, _), then deletes
%   every key of Deletions in order with CLRS single-pass top-down deletion.
%   Keys that are not in the tree leave it unchanged. Tree = none if T < 2.

btree_insert_all(_, _, _) :-
    throw(error(existence_error(procedure, btree_insert_all/3), _)).

btree_delete_all(_, _, _, _) :-
    throw(error(existence_error(procedure, btree_delete_all/4), _)).
