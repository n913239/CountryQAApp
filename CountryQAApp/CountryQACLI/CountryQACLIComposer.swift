//
//  CountryQACLIComposer.swift
//  CountryQACLI
//
//  Created by mike on 2026/7/16.
//

import Foundation
import CountryQA

@MainActor
enum CountryQACLIComposer {
    static func compose(
        httpClient: HTTPClient,
        output: @escaping (String) -> Void = { print($0) }
    ) -> CountryQAConsole {
        let useCase = CountryQAFactory.makeUseCase(httpClient: httpClient)
        let presenter = CountryAnswerPresenter(view: ConsoleAnswerView(output: output))

        return CountryQAConsole(
            ask: { question in
                presenter.present(await useCase.answer(question))
            },
            output: output
        )
    }
}
