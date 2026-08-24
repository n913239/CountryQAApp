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
            guard let country = CountryMatcher.match(query, in: countries), let capital = country.capital else {
                return .countryNotFound(query: query)
            }
            return .capital(country: country.name, capital: capital)

        case let .countriesStartingWith(letters):
            let prefix = letters.uppercased()
            let matching = countries
                .map(\.name)
                .filter { $0.uppercased().hasPrefix(prefix) }
                .sorted()
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
}
