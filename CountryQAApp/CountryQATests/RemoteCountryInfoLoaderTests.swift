//
//  RemoteCountryInfoLoaderTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/28.
//

import XCTest
@testable import CountryQA

final class RemoteCountryInfoLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsCountriesDatasetURL() async throws {
        let (sut, client) = makeSUT()
        client.stub(data: makeItemsJSON([]), response: makeHTTPURLResponse(statusCode: 200), error: nil)
        
        _ = try await sut.load(query: .all)
        
        XCTAssertEqual(client.requestedURLs, [CountriesDatasetEndpoint.url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() async {
        let (sut, client) = makeSUT()
        client.stub(data: nil, response: nil, error: anyError())
        
        do {
            _ = try await sut.load(query: .all)
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertEqual(error as? RemoteCountryInfoLoader.Error, .connectivity)
        }
    }
    
    func test_load_deliversInvalidDataErrorOnMapperError() async {
        let (sut, client) = makeSUT()
        client.stub(data: Data("invalid".utf8), response: makeHTTPURLResponse(statusCode: 200), error: nil)
        
        do {
            _ = try await sut.load(query: .all)
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertEqual(error as? RemoteCountryInfoLoader.Error, .invalidData)
        }
    }
    
    func test_loadAll_deliversAllCountriesOnSuccess() async throws {
        let (sut, client) = makeSUT()
        client.stub(data: makeItemsJSON([belgiumJSON(), brazilJSON()]), response: makeHTTPURLResponse(statusCode: 200), error: nil)
        
        let result = try await sut.load(query: .all)
        
        XCTAssertEqual(result, [belgium(), brazil()])
    }
    
    func test_loadSearchByName_filtersCountriesByNameCaseInsensitively() async throws {
        let (sut, client) = makeSUT()
        client.stub(data: makeItemsJSON([belgiumJSON(), brazilJSON()]), response: makeHTTPURLResponse(statusCode: 200), error: nil)
        
        let result = try await sut.load(query: .searchByName("belgium"))
        
        XCTAssertEqual(result, [belgium()])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCountryInfoLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCountryInfoLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func belgium() -> CountryInfo {
        CountryInfo(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪", flagImageURL: URL(string: "https://flagcdn.com/w320/be.png"))
    }
    
    private func brazil() -> CountryInfo {
        CountryInfo(name: "Brazil", capital: "Brasília", cca2: "BR", flag: "🇧🇷", flagImageURL: URL(string: "https://flagcdn.com/w320/br.png"))
    }
    
    private func belgiumJSON() -> [String: Any] {
        ["name": ["common": "Belgium"], "capital": ["Brussels"], "cca2": "BE", "flag": "🇧🇪"]
    }
    
    private func brazilJSON() -> [String: Any] {
        ["name": ["common": "Brazil"], "capital": ["Brasília"], "cca2": "BR", "flag": "🇧🇷"]
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        try! JSONSerialization.data(withJSONObject: items)
    }
    
    private func makeHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

private class HTTPClientSpy: HTTPClient {
    private(set) var requestedURLs: [URL] = []
    private var stub: (data: Data?, response: HTTPURLResponse?, error: Error?)?
    
    func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.stub = (data, response, error)
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        
        if let error = stub?.error {
            throw error
        }
        
        return (stub!.data!, stub!.response!)
    }
}
