//
//  CountryQAUseCaseTests.swift
//  CountryQATests
//
//  Created by mike on 2026/8/25.
//

import XCTest
import CountryQA

final class CountryQAUseCaseTests: XCTestCase {

    func test_answer_capitalIntent_deliversCapital() async throws {
        let sut = makeSUT(
            intent: .capitalOf("Belgium"),
            countries: [makeCountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪")]
        )

        let answer = try await sut.answer("What is the capital of Belgium?")

        XCTAssertEqual(answer, .capital(country: "Belgium", capital: "Brussels"))
    }

    func test_answer_countriesStartingWithIntent_filtersByPrefixCaseInsensitively() async throws {
        let sut = makeSUT(
            intent: .countriesStartingWith("ch"),
            countries: [named("Chad"), named("Chile"), named("China"), named("Brazil")]
        )

        let answer = try await sut.answer("Which countries start with CH?")

        XCTAssertEqual(answer, .countriesStartingWith(letters: "CH", countries: ["Chad", "Chile", "China"]))
    }

    func test_answer_isoCodeIntent_deliversCode() async throws {
        let sut = makeSUT(intent: .isoCode("Greece"), countries: [makeCountryInfo(name: "Greece", cca2: "GR")])

        let answer = try await sut.answer("What is the ISO alpha-2 country code for Greece?")

        XCTAssertEqual(answer, .isoCode(country: "Greece", code: "GR"))
    }

    func test_answer_flagIntent_deliversFlag() async throws {
        let flagURL = URL(string: "https://flagcdn.com/w320/br.png")
        let sut = makeSUT(
            intent: .flagOf("Brazil"),
            countries: [makeCountryInfo(name: "Brazil", flag: "🇧🇷", flagImageURL: flagURL)]
        )

        let answer = try await sut.answer("What is the flag of Brazil?")

        XCTAssertEqual(answer, .flag(country: "Brazil", flagEmoji: "🇧🇷", flagImageURL: flagURL))
    }

    func test_answer_unknownIntent_deliversUnknown() async throws {
        let sut = makeSUT(intent: .unknown, countries: [])

        let answer = try await sut.answer("Hello world")

        XCTAssertEqual(answer, .unknown)
    }

    func test_answer_countryNotInDataset_deliversCountryNotFound() async throws {
        let sut = makeSUT(intent: .capitalOf("Atlantis"), countries: [])

        let answer = try await sut.answer("Capital of Atlantis?")

        XCTAssertEqual(answer, .countryNotFound(query: "Atlantis"))
    }

    func test_answer_resolvesAMisspelledCountry() async throws {
        let sut = makeSUT(
            intent: .capitalOf("Belgum"),
            countries: [makeCountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪"),
                        makeCountryInfo(name: "Brazil", capital: "Brasília", cca2: "BR", flag: "🇧🇷")]
        )

        let answer = try await sut.answer("capitl of Belgum")

        XCTAssertEqual(answer, .capital(country: "Belgium", capital: "Brussels"))
    }

    func test_answer_interpreterFailure_throws() async {
        let sut = CountryQAUseCase(interpreter: FailingInterpreter(), loader: CountryInfoLoaderStub { [] })

        await assertThrows { _ = try await sut.answer("Capital of Belgium?") }
    }

    func test_answer_loaderFailure_throws() async {
        let sut = CountryQAUseCase(
            interpreter: StubInterpreter(.capitalOf("Belgium")),
            loader: CountryInfoLoaderStub { throw anyError() }
        )

        await assertThrows { _ = try await sut.answer("Capital of Belgium?") }
    }

    func test_answer_loadsTheDatasetOnce() async throws {
        let loader = LoaderSpy(countries: [makeCountryInfo(name: "Belgium", capital: "Brussels")])
        let sut = CountryQAUseCase(interpreter: StubInterpreter(.capitalOf("Belgium")), loader: loader)

        _ = try await sut.answer("Capital of Belgium?")

        let callCount = await loader.loadCallCount
        XCTAssertEqual(callCount, 1)
    }

    func test_answer_doesNotLoadForAnUnknownQuestion() async throws {
        let loader = LoaderSpy(countries: [])
        let sut = CountryQAUseCase(interpreter: StubInterpreter(.unknown), loader: loader)

        _ = try await sut.answer("hello there")

        let callCount = await loader.loadCallCount
        XCTAssertEqual(callCount, 0, "An unrecognized question must not hit the dataset")
    }

    // MARK: - Helpers

    private func makeSUT(intent: QuestionIntent, countries: [CountryInfo]) -> CountryQAUseCase {
        CountryQAUseCase(interpreter: StubInterpreter(intent), loader: CountryInfoLoaderStub { countries })
    }

    private func assertThrows(
        _ block: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await block()
            XCTFail("Expected to throw", file: file, line: line)
        } catch {}
    }
}

// MARK: - Test doubles

private func makeCountryInfo(
    name: String,
    capital: String? = nil,
    cca2: String? = nil,
    flag: String? = nil,
    flagImageURL: URL? = nil
) -> CountryInfo {
    CountryInfo(name: name, capital: capital, cca2: cca2, flag: flag, flagImageURL: flagImageURL)
}

private func named(_ name: String) -> CountryInfo {
    makeCountryInfo(name: name)
}

private func anyError() -> NSError {
    NSError(domain: "any", code: 0)
}

private struct StubInterpreter: QuestionInterpreter {
    let intent: QuestionIntent
    init(_ intent: QuestionIntent) { self.intent = intent }
    func interpret(_ text: String) async throws -> QuestionIntent { intent }
}

private struct FailingInterpreter: QuestionInterpreter {
    func interpret(_ text: String) async throws -> QuestionIntent {
        throw NSError(domain: "interpreter", code: 0)
    }
}

private final class CountryInfoLoaderStub: CountryInfoLoader {
    private let stub: () async throws -> [CountryInfo]

    init(_ stub: @escaping () async throws -> [CountryInfo]) {
        self.stub = stub
    }

    func load() async throws -> [CountryInfo] {
        try await stub()
    }
}

private actor LoaderSpy: CountryInfoLoader {
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
