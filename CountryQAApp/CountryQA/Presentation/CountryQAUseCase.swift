//
//  CountryQAUseCase.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public final class CountryQAUseCase {
    private let classifier: QuestionClassifier
    private let loader: CountryInfoLoader

    public init(classifier: QuestionClassifier, loader: CountryInfoLoader) {
        self.classifier = classifier
        self.loader = loader
    }

    public func answer(_ question: String) async -> CountryAnswer {
        let classified = classifier.classify(question)

        if case .unknown = classified {
            return .unknown
        }

        let countries: [CountryInfo]
        do {
            countries = try await loader.load()
        } catch {
            return .loadingFailed
        }

        switch classified {
        case let .capital(query):
            guard let country = CountryMatcher.match(query, in: countries), let capital = country.capital else {
                return .countryNotFound(query: query)
            }
            return .capital(country: country.name, capital: capital)

        case let .countriesStartingWith(letters):
            let matching = countries
                .map(\.name)
                .filter { $0.uppercased().hasPrefix(letters) }
                .sorted()
            return .countriesStartingWith(letters: letters, countries: matching)

        case let .isoCode(query):
            guard let country = CountryMatcher.match(query, in: countries), let code = country.cca2 else {
                return .countryNotFound(query: query)
            }
            return .isoCode(country: country.name, code: code)

        case let .flag(query):
            guard let country = CountryMatcher.match(query, in: countries), let flag = country.flag else {
                return .countryNotFound(query: query)
            }
            return .flag(country: country.name, flagEmoji: flag, flagImageURL: country.flagImageURL)

        case .unknown:
            return .unknown
        }
    }
}
