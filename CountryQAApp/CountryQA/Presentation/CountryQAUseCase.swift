//
//  CountryQAUseCase.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public final class CountryQAUseCase {
    private let interpreter: QuestionInterpreter
    private let loader: CountryInfoLoader

    public init(interpreter: QuestionInterpreter, loader: CountryInfoLoader) {
        self.interpreter = interpreter
        self.loader = loader
    }

    /// Throws when interpreting or loading fails, so the caller can offer a retry. A question that
    /// is understood but unanswerable is not a failure - it returns `.unknown` or `.countryNotFound`.
    public func answer(_ question: String) async throws -> CountryAnswer {
        let intent = try await interpreter.interpret(question)

        if case .unknown = intent {
            return .unknown
        }

        let countries = try await loader.load()

        switch intent {
        case let .capitalOf(query):
            guard let country = CountryMatcher.match(query, in: countries) else {
                return .countryNotFound(query: query)
            }
            guard let capital = country.capital else {
                return .noKnownCapital(country: country.name)
            }
            return .capital(country: country.name, capital: capital)

        case let .countriesStartingWith(letters):
            let prefix = letters.uppercased()
            let matching = countries
                .map(\.name)
                .filter { Self.comparable($0).hasPrefix(Self.comparable(prefix)) }
                .sorted { Self.comparable($0) < Self.comparable($1) }
            return .countriesStartingWith(letters: prefix, countries: matching)

        case let .isoCode(query):
            guard let country = CountryMatcher.match(query, in: countries), let code = country.cca2 else {
                return .countryNotFound(query: query)
            }
            return .isoCode(country: country.name, code: code)

        case let .flagOf(query):
            guard let country = CountryMatcher.match(query, in: countries), let flag = country.flag else {
                return .countryNotFound(query: query)
            }
            return .flag(country: country.name, flagEmoji: flag, flagImageURL: country.flagImageURL)

        case .unknown:
            return .unknown
        }
    }

    /// The dataset spells some names with diacritics ("Åland Islands"), which no one types when
    /// asking which countries start with a letter. Folding both sides keeps such a name in the
    /// answer and sorts it among the plain letters instead of after "Z".
    private static func comparable(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }
}
