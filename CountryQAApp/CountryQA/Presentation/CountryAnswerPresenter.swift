//
//  CountryAnswerPresenter.swift
//  CountryQA
//
//  Created by mike on 2026/6/25.
//

import Foundation

public final class CountryAnswerPresenter {
    private let view: CountryAnswerView
    
    public init(view: CountryAnswerView) {
        self.view = view
    }
    
    @MainActor
    public func present(_ answer: CountryAnswer) {
        view.display(makeViewModel(for: answer))
    }
    
    // MARK: - Mapping
    
    private func makeViewModel(for answer: CountryAnswer) -> CountryAnswerViewModel {
        switch answer {
        case let .capital(country, capital):
            return CountryAnswerViewModel(message: String(format: Self.localized("CAPITAL_ANSWER_FORMAT"), country, capital))
            
        case let .countriesStartingWith(letters, countries):
            let message = countries.isEmpty
            ? String(format: Self.localized("STARTS_WITH_NONE_FORMAT"), letters)
            : String(format: Self.localized("STARTS_WITH_ANSWER_FORMAT"), letters, countries.joined(separator: ", "))
            return CountryAnswerViewModel(message: message)
            
        case let .isoCode(country, code):
            return CountryAnswerViewModel(message: String(format: Self.localized("ISO_CODE_ANSWER_FORMAT"), country, code))
            
        case let .flag(country, flagEmoji, flagImageURL):
            return CountryAnswerViewModel(
                message: String(format: Self.localized("FLAG_ANSWER_FORMAT"), country, flagEmoji),
                flagEmoji: flagEmoji,
                flagImageURL: flagImageURL
            )
            
        case .unknown:
            return CountryAnswerViewModel(message: Self.localized("UNKNOWN_QUESTION_MESSAGE"))
            
        case let .countryNotFound(query):
            return CountryAnswerViewModel(message: String(format: Self.localized("COUNTRY_NOT_FOUND_FORMAT"), query))
            
        case .loadingFailed:
            return CountryAnswerViewModel(message: Self.localized("LOADING_FAILED_MESSAGE"), showsRetry: true)
        }
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
