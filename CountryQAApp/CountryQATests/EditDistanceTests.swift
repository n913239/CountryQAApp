//
//  EditDistanceTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class EditDistanceTests: XCTestCase {

    func test_editDistance_isZeroForIdenticalStrings() {
        XCTAssertEqual(editDistance("capital", "capital"), 0)
    }

    func test_editDistance_isTheLengthOfTheOtherStringWhenOneIsEmpty() {
        XCTAssertEqual(editDistance("", "flag"), 4)
        XCTAssertEqual(editDistance("flag", ""), 4)
    }

    func test_editDistance_countsInsertionsSubstitutionsAndDeletions() {
        XCTAssertEqual(editDistance("flag", "flags"), 1)
        XCTAssertEqual(editDistance("code", "core"), 1)
        XCTAssertEqual(editDistance("capital", "capita"), 1)
    }

    func test_editDistance_countsASwapOfTwoAdjacentCharactersAsASingleEdit() {
        XCTAssertEqual(editDistance("captial", "capital"), 1)
        XCTAssertEqual(editDistance("falg", "flag"), 1)
    }

    func test_editDistance_keepsUnrelatedShortWordsApart() {
        XCTAssertEqual(editDistance("cape", "code"), 2, "A country such as Cape Verde must not read as the word code")
        XCTAssertEqual(editDistance("benin", "begin"), 1)
    }
}
