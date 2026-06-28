//
//  CountryQAAPIEndToEndTests.swift
//  CountryQAAPIEndToEndTests
//
//  Created by mike on 2026/6/24.
//

import XCTest
import CountryQA

/// End-to-end tests that hit the live mledoze countries dataset.
///
/// These tests are intentionally excluded from the CI test plan because they depend on
/// network reachability and the third-party dataset being up. Run them locally before
/// shipping changes that touch the networking or mapper layers.
final class CountryQAAPIEndToEndTests: XCTestCase {
    
    func test_endToEndLoadAll_deliversFullCountryList() async {
        switch await loadResult(query: .all) {
        case let .success(countries):
            XCTAssertGreaterThan(countries.count, 200, "Expected the full country dataset, got \(countries.count)")
            let belgium = countries.first { $0.name == "Belgium" }
            XCTAssertEqual(belgium?.capital, "Brussels")
            XCTAssertEqual(belgium?.cca2, "BE")
            XCTAssertEqual(belgium?.flagImageURL, URL(string: "https://flagcdn.com/w320/be.png"))
            
        case let .failure(error):
            XCTFail("Expected a successful load, got \(error) instead")
        }
    }
    
    func test_endToEndSearchByName_deliversMatchingCountry() async {
        switch await loadResult(query: .searchByName("Belgium")) {
        case let .success(countries):
            XCTAssertEqual(countries.first?.name, "Belgium")
            XCTAssertEqual(countries.first?.capital, "Brussels")
            
        case let .failure(error):
            XCTFail("Expected a successful search, got \(error) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func loadResult(query: CountryQuery, file: StaticString = #filePath, line: UInt = #line) async -> Result<[CountryInfo], Error> {
        let loader = RemoteCountryInfoLoader(client: ephemeralClient(file: file, line: line))
        do {
            return .success(try await loader.load(query: query))
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
