//
//  CountriesDatasetEndpointTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/28.
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
