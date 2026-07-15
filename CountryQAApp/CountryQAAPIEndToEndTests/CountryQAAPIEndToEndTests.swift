//
//  CountryQAAPIEndToEndTests.swift
//  CountryQAAPIEndToEndTests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class CountryQAAPIEndToEndTests: XCTestCase {
    
    func test_endToEndLoad_deliversTheFullCountryDataset() async {
        switch await loadResult() {
        case let .success(countries):
            XCTAssertGreaterThan(countries.count, 200, "Expected the full country dataset, got \(countries.count)")
            
            let belgium = countries.first { $0.name == "Belgium" }
            XCTAssertEqual(belgium?.capital, "Brussels")
            XCTAssertEqual(belgium?.cca2, "BE")
            XCTAssertEqual(belgium?.flag, "🇧🇪")
            XCTAssertEqual(belgium?.flagImageURL, URL(string: "https://flagcdn.com/w320/be.png"))
            
        case let .failure(error):
            XCTFail("Expected a successful load, got \(error) instead")
        }
    }
    
    func test_endToEndLoad_deliversCountriesTheMatcherCanResolve() async {
        switch await loadResult() {
        case let .success(countries):
            XCTAssertEqual(CountryMatcher.match("Benin", in: countries)?.capital, "Porto-Novo")
            XCTAssertEqual(CountryMatcher.match("Cape Verde", in: countries)?.flag, "🇨🇻")
            XCTAssertEqual(CountryMatcher.match("Congo", in: countries)?.name, "Congo", "Expected the exact match, not DR Congo")
            XCTAssertEqual(CountryMatcher.match("belgim", in: countries)?.name, "Belgium")
            
        case let .failure(error):
            XCTFail("Expected a successful load, got \(error) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func loadResult(file: StaticString = #filePath, line: UInt = #line) async -> Result<[CountryInfo], Error> {
        let loader = RemoteCountryInfoLoader(
            client: ephemeralClient(file: file, line: line),
            url: CountriesDatasetEndpoint.url
        )
        do {
            return .success(try await loader.load())
        } catch {
            return .failure(error)
        }
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        let client = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
