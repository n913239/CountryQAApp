//
//  CountryInfoTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/24.
//

import XCTest
import CountryQA

final class CountryInfoTests: XCTestCase {
    
    func test_countryInfo_holdsProperties() {
        let flagURL = URL(string: "https://flagcdn.com/w320/be.png")
        let item = CountryInfo(
            name: "Belgium",
            capital: "Brussels",
            cca2: "BE",
            flag: "🇧🇪",
            flagImageURL: flagURL
        )
        
        XCTAssertEqual(item.name, "Belgium")
        XCTAssertEqual(item.capital, "Brussels")
        XCTAssertEqual(item.cca2, "BE")
        XCTAssertEqual(item.flag, "🇧🇪")
        XCTAssertEqual(item.flagImageURL, flagURL)
    }
}
