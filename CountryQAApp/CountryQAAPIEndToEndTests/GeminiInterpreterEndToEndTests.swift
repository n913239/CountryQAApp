//
//  GeminiInterpreterEndToEndTests.swift
//  CountryQAAPIEndToEndTests
//
//  Created by mike on 2026/8/26.
//

import XCTest
import CountryQA

/// Hits the real Gemini API, so it is kept out of the CI test plan and skips unless a key is set:
/// `GEMINI_API_KEY=... xcodebuild test -scheme CountryQAAPIEndToEnd ...`
final class GeminiInterpreterEndToEndTests: XCTestCase {

    func test_interpret_realGemini_classifiesNaturallyPhrasedQuestions() async throws {
        let sut = try makeSUT()

        try await assert("What's the capital of Belgium?", isCapitalOf: "belgium", sut: sut)
        try await assert("belgium capital pls", isCapitalOf: "belgium", sut: sut)
        try await assert("which countries start with GR?", isCountriesStartingWith: "gr", sut: sut)
        try await assert("countries starting GR", isCountriesStartingWith: "gr", sut: sut)
        try await assert("iso code for greece", isIsoCodeOf: "greece", sut: sut)
        try await assert("whats teh flag of brasil", isFlagOf: "brasil", sut: sut)
    }

    func test_interpret_realGemini_returnsUnknownForUnrelatedQuestions() async throws {
        let sut = try makeSUT()

        let intent = try await sut.interpret("how is the weather today?")

        XCTAssertEqual(intent, .unknown, "Expected an unrelated question to be classified as unknown")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> GeminiQuestionInterpreter {
        guard let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !apiKey.isEmpty else {
            throw XCTSkip("Set GEMINI_API_KEY to run the Gemini end-to-end test")
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 20
        return GeminiQuestionInterpreter(
            client: URLSessionHTTPClient(session: URLSession(configuration: configuration)),
            apiKey: apiKey
        )
    }

    private func assert(
        _ question: String,
        isCapitalOf country: String,
        sut: GeminiQuestionInterpreter,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        guard case let .capitalOf(argument) = try await sut.interpret(question) else {
            return XCTFail("Expected capitalOf for \"\(question)\"", file: file, line: line)
        }
        XCTAssertTrue(argument.lowercased().contains(country), "Expected \(country) in \"\(argument)\"", file: file, line: line)
    }

    private func assert(
        _ question: String,
        isCountriesStartingWith letters: String,
        sut: GeminiQuestionInterpreter,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        guard case let .countriesStartingWith(argument) = try await sut.interpret(question) else {
            return XCTFail("Expected countriesStartingWith for \"\(question)\"", file: file, line: line)
        }
        XCTAssertTrue(argument.lowercased().contains(letters), "Expected \(letters) in \"\(argument)\"", file: file, line: line)
    }

    private func assert(
        _ question: String,
        isIsoCodeOf country: String,
        sut: GeminiQuestionInterpreter,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        guard case let .isoCode(argument) = try await sut.interpret(question) else {
            return XCTFail("Expected isoCode for \"\(question)\"", file: file, line: line)
        }
        XCTAssertTrue(argument.lowercased().contains(country), "Expected \(country) in \"\(argument)\"", file: file, line: line)
    }

    private func assert(
        _ question: String,
        isFlagOf country: String,
        sut: GeminiQuestionInterpreter,
        file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        guard case let .flagOf(argument) = try await sut.interpret(question) else {
            return XCTFail("Expected flagOf for \"\(question)\"", file: file, line: line)
        }
        XCTAssertTrue(argument.lowercased().contains(country), "Expected \(country) in \"\(argument)\"", file: file, line: line)
    }
}
