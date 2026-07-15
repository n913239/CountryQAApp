//
//  CountriesDatasetEndpointTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
@testable import CountryQA

final class CountriesDatasetEndpointTests: XCTestCase {

    func test_url_pointsToMledozeCountriesDataset() {
        XCTAssertEqual(
            CountriesDatasetEndpoint.url.absoluteString,
            "https://raw.githubusercontent.com/mledoze/countries/master/countries.json"
        )
    }
}
