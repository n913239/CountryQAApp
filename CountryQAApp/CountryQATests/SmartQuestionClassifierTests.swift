//
//  SmartQuestionClassifierTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/24.
//

import XCTest
import CountryQA

final class SmartQuestionClassifierTests: XCTestCase {
    
    // MARK: capital
    
    func test_classify_capital_prepositionPhrasing() {
        XCTAssertEqual(classify("What is the capital of France?"), .capital(country: "france"))
    }
    
    func test_classify_capital_possessivePhrasing() {
        XCTAssertEqual(classify("France's capital?"), .capital(country: "france"))
    }
    
    func test_classify_capital_multiWordCountry_possessive() {
        XCTAssertEqual(classify("What's South Africa's capital?"), .capital(country: "south africa"))
    }
    
    func test_classify_capital_multiWordCountry_preposition() {
        XCTAssertEqual(classify("capital of the United States"), .capital(country: "united states"))
    }
    
    func test_classify_capital_fuzzyKeyword() {
        XCTAssertEqual(classify("what is the capitol of japan"), .capital(country: "japan"))
    }
    
    // MARK: countriesStartingWith
    
    func test_classify_startsWith_simple() {
        XCTAssertEqual(classify("Which countries start with A?"), .countriesStartingWith(letters: "A"))
    }
    
    func test_classify_startsWith_letterPhrasing() {
        XCTAssertEqual(classify("countries beginning with the letter z"), .countriesStartingWith(letters: "Z"))
    }
    
    // MARK: isoCode
    
    func test_classify_isoCode_preposition() {
        XCTAssertEqual(classify("What is the ISO code for Japan?"), .isoCode(country: "japan"))
    }
    
    func test_classify_isoCode_possessive() {
        XCTAssertEqual(classify("Germany's country code"), .isoCode(country: "germany"))
    }
    
    // MARK: flag
    
    func test_classify_flag_preposition() {
        XCTAssertEqual(classify("Show me the flag of Brazil"), .flag(country: "brazil"))
    }
    
    func test_classify_flag_terse() {
        XCTAssertEqual(classify("brazil flag"), .flag(country: "brazil"))
    }
    
    // MARK: - Challenge spec examples
    
    func test_classify_matchesChallengeSpecExamples() {
        XCTAssertEqual(classify("What is the capital of Belgium?"), .capital(country: "belgium"))
        XCTAssertEqual(classify("Which countries start with CH?"), .countriesStartingWith(letters: "CH"))
        XCTAssertEqual(classify("What is the ISO alpha-2 country code for Greece?"), .isoCode(country: "greece"))
        XCTAssertEqual(classify("What is the flag of Brazil?"), .flag(country: "brazil"))
    }
    
    // MARK: - Noise word stripping
    
    func test_classify_stripsTrailingNoiseWords() {
        XCTAssertEqual(classify("greece country code"), .isoCode(country: "greece"))
    }
    
    func test_classify_unknown_whenPrepositionHasNoCountry() {
        XCTAssertEqual(classify("what is the capital of"), .unknown)
    }
    
    // MARK: unknown
    
    func test_classify_unknown_whenNoKeyword() {
        XCTAssertEqual(classify("hello there"), .unknown)
    }
    
    func test_classify_unknown_whenNoCountry() {
        XCTAssertEqual(classify("what is the capital"), .unknown)
    }
    
    // MARK: - Helpers
    
    private func classify(_ question: String, file: StaticString = #filePath, line: UInt = #line) -> ClassifiedQuestion {
        let sut = SmartQuestionClassifier()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut.classify(question)
    }
}
