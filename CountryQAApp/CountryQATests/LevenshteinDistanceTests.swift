//
//  LevenshteinDistanceTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/24.
//

import XCTest
@testable import CountryQA

final class LevenshteinDistanceTests: XCTestCase {
    
    func test_distance_isZeroForIdenticalStrings() {
        XCTAssertEqual(levenshteinDistance("capital", "capital"), 0)
    }
    
    func test_distance_equalsOtherLengthWhenOneIsEmpty() {
        XCTAssertEqual(levenshteinDistance("", "flag"), 4)
        XCTAssertEqual(levenshteinDistance("code", ""), 4)
    }
    
    func test_distance_countsSingleEdits() {
        XCTAssertEqual(levenshteinDistance("capitol", "capital"), 1)
        XCTAssertEqual(levenshteinDistance("flg", "flag"), 1)
        XCTAssertEqual(levenshteinDistance("codee", "code"), 1)
    }
    
    func test_distance_countsMultipleEdits() {
        XCTAssertEqual(levenshteinDistance("kitten", "sitting"), 3)
    }
}
