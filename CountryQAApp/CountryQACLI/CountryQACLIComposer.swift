//
//  CountryQACLIComposer.swift
//  CountryQACLI
//
//  Created by mike on 2026/8/26.
//

import Foundation
import CountryQA

@MainActor
enum CountryQACLIComposer {
    static func compose(
        httpClient: HTTPClient,
        interpreter: QuestionInterpreter,
        output: @escaping (String) -> Void = { print($0) }
    ) -> CountryQAConsole {
        let useCase = CountryQAFactory.makeUseCase(interpreter: interpreter, httpClient: httpClient)
        let presenter = CountryAnswerPresenter(view: ConsoleAnswerView(output: output))

        return CountryQAConsole(
            ask: { question in
                do {
                    presenter.present(try await useCase.answer(question))
                } catch {
                    presenter.presentError(retrying: question)
                }
            },
            output: output
        )
    }
}
