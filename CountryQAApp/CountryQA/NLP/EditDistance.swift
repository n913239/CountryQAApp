//
//  EditDistance.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

/// Optimal string alignment distance: Levenshtein plus a transposition of two adjacent
/// characters as a single edit, so a swapped pair of letters costs the same as any other typo.
public func editDistance(_ s1: String, _ s2: String) -> Int {
    let a = Array(s1)
    let b = Array(s2)
    if a.isEmpty { return b.count }
    if b.isEmpty { return a.count }

    var distance = Array(
        repeating: Array(repeating: 0, count: b.count + 1),
        count: a.count + 1
    )

    for i in 0...a.count { distance[i][0] = i }
    for j in 0...b.count { distance[0][j] = j }

    for i in 1...a.count {
        for j in 1...b.count {
            let substitutionCost = a[i - 1] == b[j - 1] ? 0 : 1

            distance[i][j] = min(
                distance[i - 1][j] + 1,
                distance[i][j - 1] + 1,
                distance[i - 1][j - 1] + substitutionCost
            )

            if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                distance[i][j] = min(distance[i][j], distance[i - 2][j - 2] + 1)
            }
        }
    }

    return distance[a.count][b.count]
}
