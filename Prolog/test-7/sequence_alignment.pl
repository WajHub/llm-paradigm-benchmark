:- module(sequence_alignment, [
    alignment_score/7,
    alignment_align/7
]).

% Global alignment of two sequences with an affine gap penalty (Gotoh).
%
% Inputs A and B are atoms (e.g. 'GATTACA', ''), compared character by
% character (case-sensitive); they never contain '-'. All four integer
% parameters are >= 0.
%
% Score of an alignment: for every column without '-', +MatchScore if the two
% characters are equal, -MismatchPenalty otherwise; minus, for every gap
% (maximal run of consecutive '-' in the same row) of length L >= 1,
% GapOpen + L * GapExtend. A column with '-' in both rows is not allowed.
% End gaps are penalised like any other gap; scores may be negative.
%
% alignment_score(+A, +B, +MatchScore, +MismatchPenalty, +GapOpen, +GapExtend, -Score)
%   Score is the maximum score (an integer) over all global alignments of A and B.
%
% alignment_align(+A, +B, +MatchScore, +MismatchPenalty, +GapOpen, +GapExtend, -Result)
%   Result = alignment(Score, AlignedA, AlignedB)
%   where AlignedA and AlignedB are atoms of equal length over the characters of
%   A/B plus '-', removing '-' from AlignedA gives A and from AlignedB gives B,
%   and their score is Score (the optimum). Any optimal alignment is accepted.
%   Empty vs empty gives alignment(0, '', '').

alignment_score(_, _, _, _, _, _, _) :-
    throw(error(existence_error(procedure, alignment_score/7), _)).

alignment_align(_, _, _, _, _, _, _) :-
    throw(error(existence_error(procedure, alignment_align/7), _)).
