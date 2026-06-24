//
//  RestCountriesEndpointTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/24.
//

import XCTest
@testable import CountryQA

final class RestCountriesEndpointTests: XCTestCase {
    
    func test_searchByName_buildsRestCountriesNameURL() {
        let url = RestCountriesEndpoint.url(for: .searchByName("Belgium"))
        
        XCTAssertEqual(url.absoluteString, "https://restcountries.com/v3.1/name/Belgium?fields=name,capital,cca2,flag,flags")
    }
    
    func test_searchByName_percentEncodesMultiWordCountry() {
        let url = RestCountriesEndpoint.url(for: .searchByName("South Africa"))
        
        XCTAssertEqual(url.absoluteString, "https://restcountries.com/v3.1/name/South%20Africa?fields=name,capital,cca2,flag,flags")
    }
    
    func test_all_buildsRestCountriesAllURL() {
        let url = RestCountriesEndpoint.url(for: .all)
        
        XCTAssertEqual(url.absoluteString, "https://restcountries.com/v3.1/all?fields=name")
    }
}
