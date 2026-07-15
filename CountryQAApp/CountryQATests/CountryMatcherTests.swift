//
//  CountryMatcherTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class CountryMatcherTests: XCTestCase {

    func test_match_deliversNilForAnEmptyQuery() {
        XCTAssertNil(CountryMatcher.match("", in: countries))
        XCTAssertNil(CountryMatcher.match("   ", in: countries))
    }

    func test_match_deliversNilWhenNothingIsCloseEnough() {
        XCTAssertNil(CountryMatcher.match("Zimbabwezzz", in: countries))
        XCTAssertNil(CountryMatcher.match("Atlantis", in: countries))
    }

    func test_match_prefersAnExactNameOverALongerNameContainingIt() {
        let matched = CountryMatcher.match("Congo", in: countries)

        XCTAssertEqual(matched?.name, "Congo", "Expected the exact match, not DR Congo")
    }

    func test_match_isCaseInsensitive() {
        XCTAssertEqual(CountryMatcher.match("belgium", in: countries)?.name, "Belgium")
        XCTAssertEqual(CountryMatcher.match("BELGIUM", in: countries)?.name, "Belgium")
    }

    func test_match_ignoresPunctuationInTheCountryName() {
        XCTAssertEqual(CountryMatcher.match("guinea bissau", in: countries)?.name, "Guinea-Bissau")
    }

    func test_match_resolvesAnAlternativeName() {
        XCTAssertEqual(CountryMatcher.match("USA", in: countries)?.name, "United States")
        XCTAssertEqual(CountryMatcher.match("Brasil", in: countries)?.name, "Brazil")
    }

    func test_match_resolvesATwoLetterCode() {
        XCTAssertEqual(CountryMatcher.match("BR", in: countries)?.name, "Brazil")
    }

    func test_match_resolvesAMisspelledCountry() {
        XCTAssertEqual(CountryMatcher.match("belgim", in: countries)?.name, "Belgium")
        XCTAssertEqual(CountryMatcher.match("brazl", in: countries)?.name, "Brazil")
    }

    // MARK: - Helpers

    private var countries: [CountryInfo] {
        [
            makeCountry(name: "Belgium", cca2: "BE"),
            makeCountry(name: "Brazil", cca2: "BR", alternativeNames: ["Brasil", "BRA"]),
            makeCountry(name: "Congo", cca2: "CG"),
            makeCountry(name: "DR Congo", cca2: "CD"),
            makeCountry(name: "Guinea-Bissau", cca2: "GW"),
            makeCountry(name: "United States", cca2: "US", alternativeNames: ["USA", "United States of America"])
        ]
    }

    private func makeCountry(
        name: String,
        cca2: String,
        alternativeNames: [String] = []
    ) -> CountryInfo {
        CountryInfo(
            name: name,
            capital: "any capital",
            cca2: cca2,
            flag: "any flag",
            flagImageURL: nil,
            alternativeNames: alternativeNames
        )
    }
}
