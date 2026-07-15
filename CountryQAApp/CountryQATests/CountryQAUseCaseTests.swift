//
//  CountryQAUseCaseTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class CountryQAUseCaseTests: XCTestCase {

    func test_answer_capitalQuestion_deliversCapital() async {
        let classifier = QuestionClassifierStub(result: .capital(country: "Belgium"))
        let loader = CountryInfoLoaderStub {
            [makeCountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪")]
        }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("What is the capital of Belgium?")

        XCTAssertEqual(answer, .capital(country: "Belgium", capital: "Brussels"))
    }

    func test_answer_startsWithQuestion_filtersCountriesByPrefix() async {
        let classifier = QuestionClassifierStub(result: .countriesStartingWith(letters: "CH"))
        let loader = CountryInfoLoaderStub {
            [makeCountryInfo(name: "Chad"), makeCountryInfo(name: "Chile"),
             makeCountryInfo(name: "China"), makeCountryInfo(name: "Brazil")]
        }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("Which countries start with CH?")

        XCTAssertEqual(answer, .countriesStartingWith(letters: "CH", countries: ["Chad", "Chile", "China"]))
    }

    func test_answer_isoCodeQuestion_deliversCode() async {
        let classifier = QuestionClassifierStub(result: .isoCode(country: "Greece"))
        let loader = CountryInfoLoaderStub {
            [makeCountryInfo(name: "Greece", cca2: "GR")]
        }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("What is the ISO alpha-2 country code for Greece?")

        XCTAssertEqual(answer, .isoCode(country: "Greece", code: "GR"))
    }

    func test_answer_flagQuestion_deliversFlag() async {
        let classifier = QuestionClassifierStub(result: .flag(country: "Brazil"))
        let flagURL = URL(string: "https://flagcdn.com/w320/br.png")
        let loader = CountryInfoLoaderStub {
            [makeCountryInfo(name: "Brazil", flag: "🇧🇷", flagImageURL: flagURL)]
        }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("What is the flag of Brazil?")

        XCTAssertEqual(answer, .flag(country: "Brazil", flagEmoji: "🇧🇷", flagImageURL: flagURL))
    }

    func test_answer_unknownQuestion_deliversUnknown() async {
        let classifier = QuestionClassifierStub(result: .unknown)
        let loader = CountryInfoLoaderStub { [] }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("Hello world")

        XCTAssertEqual(answer, .unknown)
    }

    func test_answer_loaderFailure_deliversLoadingFailed() async {
        let classifier = QuestionClassifierStub(result: .capital(country: "Belgium"))
        let loader = CountryInfoLoaderStub { throw anyError() }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("Capital of Belgium?")

        XCTAssertEqual(answer, .loadingFailed)
    }

    func test_answer_countryNotFound_deliversCountryNotFound() async {
        let classifier = QuestionClassifierStub(result: .capital(country: "Atlantis"))
        let loader = CountryInfoLoaderStub { [] }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("Capital of Atlantis?")

        XCTAssertEqual(answer, .countryNotFound(query: "Atlantis"))
    }

    func test_answer_loadsTheDatasetOnce() async {
        let classifier = QuestionClassifierStub(result: .capital(country: "Belgium"))
        let loader = LoaderSpy(countries: [makeCountryInfo(name: "Belgium", capital: "Brussels")])
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        _ = await sut.answer("Capital of Belgium?")

        let callCount = await loader.loadCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_answer_doesNotLoadForAnUnknownQuestion() async {
        let classifier = QuestionClassifierStub(result: .unknown)
        let loader = LoaderSpy(countries: [])
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        _ = await sut.answer("hello there")

        let callCount = await loader.loadCallCount
        XCTAssertEqual(callCount, 0, "An unrecognized question must not hit the network")
    }

    func test_answer_resolvesAMisspelledCountry() async {
        let classifier = QuestionClassifierStub(result: .capital(country: "Belgum"))
        let loader = CountryInfoLoaderStub {
            [makeCountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪"),
             makeCountryInfo(name: "Brazil", capital: "Brasília", cca2: "BR", flag: "🇧🇷")]
        }
        let sut = CountryQAUseCase(classifier: classifier, loader: loader)

        let answer = await sut.answer("capitl of Belgum")

        XCTAssertEqual(answer, .capital(country: "Belgium", capital: "Brussels"))
    }

}

// MARK: - Helpers

private func makeCountryInfo(
    name: String,
    capital: String? = nil,
    cca2: String? = nil,
    flag: String? = nil,
    flagImageURL: URL? = nil
) -> CountryInfo {
    CountryInfo(name: name, capital: capital, cca2: cca2, flag: flag, flagImageURL: flagImageURL)
}

private func anyError() -> NSError {
    NSError(domain: "any", code: 0)
}

final class QuestionClassifierStub: QuestionClassifier {
    private let result: ClassifiedQuestion

    init(result: ClassifiedQuestion) {
        self.result = result
    }

    func classify(_ question: String) -> ClassifiedQuestion {
        result
    }
}

final class CountryInfoLoaderStub: CountryInfoLoader {
    private let stub: () async throws -> [CountryInfo]

    init(_ stub: @escaping () async throws -> [CountryInfo]) {
        self.stub = stub
    }

    func load() async throws -> [CountryInfo] {
        try await stub()
    }
}

actor LoaderSpy: CountryInfoLoader {
    private(set) var loadCallCount = 0
    private let countries: [CountryInfo]

    init(countries: [CountryInfo]) {
        self.countries = countries
    }

    func load() async throws -> [CountryInfo] {
        loadCallCount += 1
        return countries
    }
}
