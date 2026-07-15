//
//  CachingCountryInfoLoaderTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

final class CachingCountryInfoLoaderTests: XCTestCase {

    func test_init_doesNotLoad() async {
        let (_, decoratee) = makeSUT()

        let callCount = await decoratee.loadCallCount
        XCTAssertEqual(callCount, 0)
    }

    func test_load_deliversTheDecorateesCountries() async throws {
        let countries = [makeCountry(name: "Belgium")]
        let (sut, decoratee) = makeSUT()
        await decoratee.stub(.success(countries))

        let received = try await sut.load()

        XCTAssertEqual(received, countries)
    }

    func test_loadTwice_onlyLoadsFromTheDecorateeOnce() async throws {
        let (sut, decoratee) = makeSUT()
        await decoratee.stub(.success([makeCountry(name: "Belgium")]))

        _ = try await sut.load()
        _ = try await sut.load()
        _ = try await sut.load()

        let callCount = await decoratee.loadCallCount
        XCTAssertEqual(callCount, 1, "The dataset is a single document, so it must be fetched once and reused")
    }

    func test_load_deliversTheDecorateesError() async {
        let (sut, decoratee) = makeSUT()
        await decoratee.stub(.failure(anyError()))

        do {
            _ = try await sut.load()
            XCTFail("Expected the decoratee error to be delivered")
        } catch {
            XCTAssertEqual(error as NSError, anyError())
        }
    }

    func test_loadAfterAFailure_retriesTheDecoratee() async throws {
        let countries = [makeCountry(name: "Belgium")]
        let (sut, decoratee) = makeSUT()
        await decoratee.stub(.failure(anyError()))

        _ = try? await sut.load()
        await decoratee.stub(.success(countries))
        let received = try await sut.load()

        XCTAssertEqual(received, countries, "A failed load must not be cached")
        let callCount = await decoratee.loadCallCount
        XCTAssertEqual(callCount, 2)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CachingCountryInfoLoader, LoaderSpy) {
        let decoratee = LoaderSpy()
        let sut = CachingCountryInfoLoader(decoratee: decoratee)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, decoratee)
    }

    private func makeCountry(name: String) -> CountryInfo {
        CountryInfo(name: name, capital: "any", cca2: "XX", flag: "any", flagImageURL: nil)
    }

    private func anyError() -> NSError {
        NSError(domain: "any", code: 0)
    }

    private actor LoaderSpy: CountryInfoLoader {
        private(set) var loadCallCount = 0
        private var result: Result<[CountryInfo], Error> = .success([])

        func stub(_ result: Result<[CountryInfo], Error>) {
            self.result = result
        }

        func load() async throws -> [CountryInfo] {
            loadCallCount += 1
            return try result.get()
        }
    }
}
