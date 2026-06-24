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
        let url = RestCountriesEndpoint.url(for: query)
        
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.get(from: url)
        } catch {
            throw Error.connectivity
        }
        
        do {
            return try RestCountriesMapper.map(data, from: response)
        } catch {
            throw Error.invalidData
        }
    }
}
