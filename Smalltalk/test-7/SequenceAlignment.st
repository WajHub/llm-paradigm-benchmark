Object subclass: AlignmentResult [
    | score alignedA alignedB |

    AlignmentResult class >> score: s alignedA: a alignedB: b [
        ^self new initScore: s alignedA: a alignedB: b
    ]

    initScore: s alignedA: a alignedB: b [
        score := s.
        alignedA := a.
        alignedB := b.
        ^self
    ]

    score [ ^score ]
    alignedA [ ^alignedA ]
    alignedB [ ^alignedB ]
]

Object subclass: SequenceAlignment [
    scoreOf: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        ^self subclassResponsibility
    ]

    align: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        ^self subclassResponsibility
    ]
]
