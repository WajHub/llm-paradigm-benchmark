SequenceAlignment subclass: SequenceAlignmentImpl [
    scoreOf: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        self error: 'Not implemented'
    ]

    align: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        self error: 'Not implemented'
    ]
]
