//
//  LevenshteinDistance.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

public func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
    let (a, b) = (Array(s1), Array(s2))
    if a.isEmpty { return b.count }
    if b.isEmpty { return a.count }
    
    var dp = Array(0...b.count)
    
    for i in 1...a.count {
        var prev = dp[0]
        dp[0] = i
        for j in 1...b.count {
            let temp = dp[j]
            dp[j] = a[i - 1] == b[j - 1]
            ? prev
            : 1 + min(prev, dp[j], dp[j - 1])
            prev = temp
        }
    }
    return dp[b.count]
}
