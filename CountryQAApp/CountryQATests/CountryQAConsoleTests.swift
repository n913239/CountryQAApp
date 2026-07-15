//
//  CountryQAConsoleTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

@MainActor
final class CountryQAConsoleTests: XCTestCase {

    func test_greet_explainsHowToUseTheConsole() {
        let (sut, _, output) = makeSUT()

        sut.greet()

        XCTAssertEqual(output.lines.count, 3)
        XCTAssertTrue(output.lines.contains { $0.contains("capital of Belgium") }, "Expected an example question")
        XCTAssertTrue(output.lines.contains { $0.contains("quit") }, "Expected the available commands")
    }

    func test_handle_asksTheQuestion() async {
        let (sut, asked, _) = makeSUT()

        _ = await sut.handle("What is the capital of Belgium?")

        XCTAssertEqual(asked.questions, ["What is the capital of Belgium?"])
    }

    func test_handle_trimsWhitespaceAroundTheQuestion() async {
        let (sut, asked, _) = makeSUT()

        _ = await sut.handle("  What is the flag of Brazil?  ")

        XCTAssertEqual(asked.questions, ["What is the flag of Brazil?"])
    }

    func test_handle_ignoresEmptyInput() async {
        let (sut, asked, output) = makeSUT()

        let outcome = await sut.handle("   ")

        XCTAssertEqual(outcome, .waitingForInput)
        XCTAssertEqual(asked.questions, [])
        XCTAssertEqual(output.lines, [])
    }

    func test_handle_finishesOnQuit() async {
        let (sut, asked, _) = makeSUT()

        let outcome = await sut.handle("quit")

        XCTAssertEqual(outcome, .finished)
        XCTAssertEqual(asked.questions, [])
    }

    func test_handleRetry_repeatsTheLastQuestion() async {
        let (sut, asked, _) = makeSUT()

        _ = await sut.handle("What is the capital of Belgium?")
        _ = await sut.handle("retry")

        XCTAssertEqual(asked.questions, [
            "What is the capital of Belgium?",
            "What is the capital of Belgium?"
        ])
    }

    func test_handleRetry_withNoPreviousQuestion_doesNotAskRetryAsAQuestion() async {
        let (sut, asked, output) = makeSUT()

        _ = await sut.handle("retry")

        XCTAssertEqual(asked.questions, [], "\"retry\" must never be sent as a question")
        XCTAssertEqual(output.lines.count, 1)
    }

    func test_handleRetry_afterAFailedQuestion_repeatsThatQuestionRatherThanTheWordRetry() async {
        let (sut, asked, _) = makeSUT()

        _ = await sut.handle("What is the flag of Brazil?")
        _ = await sut.handle("retry")
        _ = await sut.handle("retry")

        XCTAssertEqual(asked.questions, [
            "What is the flag of Brazil?",
            "What is the flag of Brazil?",
            "What is the flag of Brazil?"
        ])
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CountryQAConsole, AskSpy, OutputSpy) {
        let asked = AskSpy()
        let output = OutputSpy()
        let sut = CountryQAConsole(
            ask: { question in asked.questions.append(question) },
            output: { line in output.lines.append(line) }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, asked, output)
    }

    @MainActor
    private final class AskSpy {
        var questions: [String] = []
    }

    @MainActor
    private final class OutputSpy {
        var lines: [String] = []
    }
}
