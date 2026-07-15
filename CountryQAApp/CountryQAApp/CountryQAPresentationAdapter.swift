//
//  CountryQAPresentationAdapter.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/16.
//

import CountryQA

@MainActor
final class CountryQAPresentationAdapter {
    private let useCase: CountryQAUseCase
    var presenter: CountryAnswerPresenter?

    init(useCase: CountryQAUseCase) {
        self.useCase = useCase
    }

    func ask(_ question: String) {
        Task {
            let answer = await useCase.answer(question)
            presenter?.present(answer)
        }
    }
}
