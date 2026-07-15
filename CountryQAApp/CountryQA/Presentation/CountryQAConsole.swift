//
//  CountryQAConsole.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

@MainActor
public final class CountryQAConsole {
    public enum Outcome: Equatable {
        case waitingForInput
        case finished
    }

    private let ask: (String) async -> Void
    private let output: (String) -> Void
    private var lastQuestion: String?

    public init(
        ask: @escaping (String) async -> Void,
        output: @escaping (String) -> Void
    ) {
        self.ask = ask
        self.output = output
    }

    public func greet() {
        output(Self.localized("CONSOLE_GREETING"))
        output(Self.localized("CONSOLE_EXAMPLES"))
        output(Self.localized("CONSOLE_COMMANDS"))
    }

    public func handle(_ input: String) async -> Outcome {
        let input = input.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !input.isEmpty else { return .waitingForInput }

        switch input.lowercased() {
        case "quit", "exit":
            return .finished

        case "retry":
            guard let lastQuestion else {
                output(Self.localized("CONSOLE_NOTHING_TO_RETRY"))
                return .waitingForInput
            }
            await ask(lastQuestion)

        default:
            lastQuestion = input
            await ask(input)
        }

        return .waitingForInput
    }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(
            key,
            tableName: "CountryQA",
            bundle: Bundle(for: CountryAnswerPresenter.self),
            comment: ""
        )
    }
}
