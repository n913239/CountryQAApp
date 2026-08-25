//
//  CountryQAPresentationAdapterTests.swift
//  CountryQAAppTests
//
//  Created by mike on 2026/8/26.
//

import XCTest
import CountryQA
@testable import CountryQAApp

@MainActor
final class CountryQAPresentationAdapterTests: XCTestCase {

    func test_ask_presentsTheAnswer() async {
        let (sut, interpreter, view) = makeSUT()
        interpreter.stub("capital of belgium", with: .capitalOf("Belgium"))

        sut.ask("capital of belgium")
        await waitUntil { !view.messages.isEmpty }

        XCTAssertEqual(view.messages.map(\.message), ["The capital of Belgium is Brussels."])
    }

    func test_ask_onFailure_presentsARetryableErrorBoundToTheQuestion() async {
        let (sut, _, view) = makeSUT()

        sut.ask("an unstubbed question")
        await waitUntil { !view.messages.isEmpty }

        XCTAssertEqual(view.messages.first?.retryQuestion, "an unstubbed question")
    }

    func test_ask_presentsAnswersInTheOrderTheQuestionsWereAsked() async {
        let (sut, interpreter, view) = makeSUT()
        interpreter.stubPending("slow question")
        interpreter.stub("fast question", with: .capitalOf("France"))

        sut.ask("slow question")
        sut.ask("fast question")
        await waitUntil { interpreter.isAwaiting("slow question") }
        interpreter.complete("slow question", with: .capitalOf("Belgium"))
        await waitUntil { view.messages.count == 2 }

        XCTAssertEqual(view.messages.map(\.message), [
            "The capital of Belgium is Brussels.",
            "The capital of France is Paris."
        ], "Expected the slow answer first: replies must keep the order the questions were asked in")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: CountryQAPresentationAdapter, interpreter: InterpreterStub, view: ViewSpy) {
        let interpreter = InterpreterStub()
        let loader = LoaderStub(countries: [
            CountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: nil, flagImageURL: nil),
            CountryInfo(name: "France", capital: "Paris", cca2: "FR", flag: nil, flagImageURL: nil)
        ])
        let view = ViewSpy()
        let sut = CountryQAPresentationAdapter(useCase: CountryQAUseCase(interpreter: interpreter, loader: loader))
        sut.presenter = CountryAnswerPresenter(view: view)
        trackForMemoryLeaks(interpreter, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, interpreter, view)
    }

    private func waitUntil(
        _ condition: @MainActor () -> Bool,
        timeout: TimeInterval = 2.0
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @MainActor
    private final class InterpreterStub: QuestionInterpreter {
        private var stubs: [String: QuestionIntent] = [:]
        private var pendingQuestions: Set<String> = []
        private var continuations: [String: CheckedContinuation<QuestionIntent, Error>] = [:]

        func stub(_ question: String, with intent: QuestionIntent) {
            stubs[question] = intent
        }

        func stubPending(_ question: String) {
            pendingQuestions.insert(question)
        }

        func isAwaiting(_ question: String) -> Bool {
            continuations[question] != nil
        }

        func complete(_ question: String, with intent: QuestionIntent) {
            continuations[question]?.resume(returning: intent)
            continuations[question] = nil
        }

        func interpret(_ text: String) async throws -> QuestionIntent {
            if pendingQuestions.contains(text) {
                return try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { continuations[text] = $0 }
                } onCancel: {
                    Task { @MainActor in
                        self.continuations[text]?.resume(throwing: CancellationError())
                        self.continuations[text] = nil
                    }
                }
            }
            guard let intent = stubs[text] else {
                throw NSError(domain: "no stub for \(text)", code: 0)
            }
            return intent
        }
    }

    private final class LoaderStub: CountryInfoLoader {
        private let countries: [CountryInfo]

        init(countries: [CountryInfo]) {
            self.countries = countries
        }

        func load() async throws -> [CountryInfo] {
            countries
        }
    }

    @MainActor
    private final class ViewSpy: CountryAnswerView {
        private(set) var messages: [CountryAnswerViewModel] = []

        func display(_ viewModel: CountryAnswerViewModel) {
            messages.append(viewModel)
        }
    }
}
