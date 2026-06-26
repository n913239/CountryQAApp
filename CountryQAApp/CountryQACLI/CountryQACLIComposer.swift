//
//  CountryQACLIComposer.swift
//  CountryQACLI
//
//  Created by mike on 2026/6/26.
//

import Foundation
import CountryQA

@MainActor
enum CountryQACLIComposer {
    static func compose(
        httpClient: HTTPClient,
        output: @escaping (String) -> Void = { print($0) }
    ) -> @MainActor (String) async -> Void {
        let useCase = CountryQAFactory.makeUseCase(httpClient: httpClient)
        let presenter = CountryAnswerPresenter(view: ConsoleAnswerView(output: output))
        return { question in
            presenter.present(await useCase.answer(question))
        }
    }
}
