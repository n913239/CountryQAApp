//
//  RemoteCountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public final class RemoteCountryInfoLoader: CountryInfoLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private let client: HTTPClient
    private let url: URL

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load() async throws -> [CountryInfo] {
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: url)
        } catch {
            throw Error.connectivity
        }

        do {
            return try CountriesDatasetMapper.map(data, from: response)
        } catch {
            throw Error.invalidData
        }
    }
}
