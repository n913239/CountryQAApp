//
//  SmartQuestionClassifierTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class SmartQuestionClassifierTests: XCTestCase {

    // MARK: - The four question types from the challenge

    func test_classify_matchesTheChallengeSpecExamples() {
        expect("What is the capital of Belgium?", toBe: .capital(country: "belgium"))
        expect("Which countries start with CH?", toBe: .countriesStartingWith(letters: "CH"))
        expect("What is the ISO alpha-2 country code for Greece?", toBe: .isoCode(country: "greece"))
        expect("What is the flag of Brazil?", toBe: .flag(country: "brazil"))
    }

    // MARK: - Country names that look like keywords

    func test_classify_doesNotMistakeACountryNameForTheStartsWithKeyword() {
        expect("What is the capital of Benin?", toBe: .capital(country: "benin"))
        expect("What is the flag of Benin?", toBe: .flag(country: "benin"))
        expect("What is the ISO alpha-2 country code for Benin?", toBe: .isoCode(country: "benin"))
    }

    func test_classify_doesNotMistakeACountryNameForTheCodeKeyword() {
        expect("What is the flag of Cape Verde?", toBe: .flag(country: "cape verde"))
        expect("What is the flag of the Cook Islands?", toBe: .flag(country: "cook islands"))
        expect("Cape Verde flag", toBe: .flag(country: "cape verde"))
    }

    // MARK: - Misspellings

    func test_classify_toleratesAMisspelledKeyword() {
        expect("whats teh captial of belgim", toBe: .capital(country: "belgim"))
        expect("What is the falg of Brazil", toBe: .flag(country: "brazil"))
        expect("What is the capitol of France?", toBe: .capital(country: "france"))
    }

    func test_classify_passesAMisspelledCountryThroughForTheMatcherToResolve() {
        expect("What is the capital of Belgim?", toBe: .capital(country: "belgim"))
        expect("What is the flag of Brasil?", toBe: .flag(country: "brasil"))
    }

    // MARK: - Phrasings

    func test_classify_understandsPossessivePhrasing() {
        expect("Belgium's capital", toBe: .capital(country: "belgium"))
        expect("Greece's ISO code", toBe: .isoCode(country: "greece"))
    }

    func test_classify_understandsTersePhrasing() {
        expect("Brazil flag", toBe: .flag(country: "brazil"))
        expect("capital of Belgium", toBe: .capital(country: "belgium"))
        expect("country code for Greece", toBe: .isoCode(country: "greece"))
    }

    func test_classify_understandsMultiWordCountries() {
        expect("What is the capital of the United Kingdom?", toBe: .capital(country: "united kingdom"))
        expect("What is the capital of Bosnia and Herzegovina?", toBe: .capital(country: "bosnia and herzegovina"))
    }

    func test_classify_keepsTheCountryWhenItContainsThePrepositionItself() {
        expect(
            "What is the capital of Republic of the Congo?",
            toBe: .capital(country: "republic of the congo")
        )
    }

    // MARK: - Starts with

    func test_classify_extractsTheLettersRegardlessOfPhrasing() {
        expect("Which countries start with CH?", toBe: .countriesStartingWith(letters: "CH"))
        expect("which countries begin with b", toBe: .countriesStartingWith(letters: "B"))
        expect("Which countries start with the letter B?", toBe: .countriesStartingWith(letters: "B"))
        expect("Which countries start with 'B'?", toBe: .countriesStartingWith(letters: "B"))
    }

    // MARK: - Unknown

    func test_classify_deliversUnknownWhenThereIsNoRecognizableQuestion() {
        expect("hello there", toBe: .unknown)
        expect("", toBe: .unknown)
        expect("what is the capital of", toBe: .unknown)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SmartQuestionClassifier {
        let sut = SmartQuestionClassifier()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(
        _ question: String,
        toBe expected: ClassifiedQuestion,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let sut = makeSUT(file: file, line: line)

        XCTAssertEqual(
            sut.classify(question),
            expected,
            "for question \"\(question)\"",
            file: file,
            line: line
        )
    }
}
