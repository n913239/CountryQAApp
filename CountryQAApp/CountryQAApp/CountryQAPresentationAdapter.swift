//
//  CountryQAPresentationAdapter.swift
//  CountryQAApp
//
//  Created by mike on 2026/8/26.
//

import CountryQA

@MainActor
final class CountryQAPresentationAdapter {
    private let useCase: CountryQAUseCase
    var presenter: CountryAnswerPresenter?

    /// Each ask waits for the previous one to finish before presenting, so answers always appear in
    /// the order the questions were asked - never out of order because two Tasks happened to race.
    private var pending: Task<Void, Never>?

    init(useCase: CountryQAUseCase) {
        self.useCase = useCase
    }

    func ask(_ question: String) {
        let previous = pending
        pending = Task { [weak self] in
            await previous?.value
            guard let self, !Task.isCancelled else { return }
            do {
                let answer = try await useCase.answer(question)
                guard !Task.isCancelled else { return }
                presenter?.present(answer)
            } catch {
                guard !Task.isCancelled else { return }
                presenter?.presentError(retrying: question)
            }
        }
    }

    deinit {
        pending?.cancel()
    }
}
