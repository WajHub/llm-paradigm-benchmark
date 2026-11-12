Knapsack subclass: KnapsackImpl [
    maxValueOf: weights values: values capacity: capacity [
        | n table |
        n := weights size.
        (n = 0 or: [capacity <= 0]) ifTrue: [^0].
        table := self buildTableWeights: weights values: values capacity: capacity.
        ^(table at: n + 1) at: capacity + 1
    ]

    solveWeights: weights values: values capacity: capacity [
        | n selected totalWeight maxValue table c |
        n := weights size.
        selected := Array new: n withAll: 0.
        totalWeight := 0.
        (n = 0 or: [capacity <= 0]) ifTrue: [
            ^KnapsackResult maxValue: 0 selected: selected totalWeight: 0
        ].
        table := self buildTableWeights: weights values: values capacity: capacity.
        maxValue := (table at: n + 1) at: capacity + 1.
        c := capacity + 1.
        n to: 1 by: -1 do: [:i | | cur prev wi |
            cur := table at: i + 1.
            prev := table at: i.
            (cur at: c) ~= (prev at: c) ifTrue: [
                wi := weights at: i.
                selected at: i put: 1.
                totalWeight := totalWeight + wi.
                c := c - wi
            ]
        ].
        ^KnapsackResult maxValue: maxValue selected: selected totalWeight: totalWeight
    ]

    buildTableWeights: weights values: values capacity: capacity [
        | n table prev |
        n := weights size.
        table := Array new: n + 1.
        prev := Array new: capacity + 1 withAll: 0.
        table at: 1 put: prev.
        1 to: n do: [:i | | row wi vi |
            row := Array new: capacity + 1 withAll: 0.
            wi := weights at: i.
            vi := values at: i.
            1 to: capacity + 1 do: [:c | | best cand |
                best := prev at: c.
                (wi < c) ifTrue: [
                    cand := (prev at: c - wi) + vi.
                    cand > best ifTrue: [best := cand]
                ].
                row at: c put: best
            ].
            table at: i + 1 put: row.
            prev := row
        ].
        ^table
    ]
]
