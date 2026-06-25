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
    
    // MARK: - Mapping（英文硬字串；Commit 16+ 抽成 Localizable.strings）
    
    private func makeViewModel(for answer: CountryAnswer) -> CountryAnswerViewModel {
        switch answer {
        case let .capital(country, capital):
            return CountryAnswerViewModel(message: "The capital of \(country) is \(capital).")
            
        case let .countriesStartingWith(letters, countries):
            let message = countries.isEmpty
            ? "No countries found starting with \(letters)."
            : "Countries starting with \(letters): \(countries.joined(separator: ", "))."
            return CountryAnswerViewModel(message: message)
            
        case let .isoCode(country, code):
            return CountryAnswerViewModel(message: "The ISO alpha-2 country code for \(country) is \(code).")
            
        case let .flag(country, flagEmoji, flagImageURL):
            return CountryAnswerViewModel(
                message: "The flag of \(country) is \(flagEmoji)",
                flagEmoji: flagEmoji,
                flagImageURL: flagImageURL
            )
            
        case .unknown:
            return CountryAnswerViewModel(
                message: "I don't understand that question. Try asking about a country's capital, ISO code, flag, or which countries start with certain letters."
            )
            
        case let .countryNotFound(query):
            return CountryAnswerViewModel(message: "Sorry, I couldn't find a country called \"\(query)\".")
            
        case .loadingFailed:
            return CountryAnswerViewModel(
                message: "Something went wrong loading the answer. Please try again.",
                showsRetry: true
            )
        }
    }
}
