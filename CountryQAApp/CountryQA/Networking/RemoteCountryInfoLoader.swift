//
//  RemoteCountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public final class RemoteCountryInfoLoader: CountryInfoLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(query: CountryQuery) async throws -> [CountryInfo] {
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: CountriesDatasetEndpoint.url)
        } catch {
            throw Error.connectivity
        }
        
        let countries: [CountryInfo]
        do {
            countries = try CountriesDatasetMapper.map(data, from: response)
        } catch {
            throw Error.invalidData
        }
        
        switch query {
        case .all:
            return countries
        case let .searchByName(name):
            return countries.filter { $0.name.range(of: name, options: .caseInsensitive) != nil }
        }
    }
}
