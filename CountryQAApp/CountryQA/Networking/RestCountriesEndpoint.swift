//
//  RestCountriesEndpoint.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public enum RestCountriesEndpoint {
    public static func url(for query: CountryQuery) -> URL {
        switch query {
        case let .searchByName(name):
            return makeURL(
                path: "/v3.1/name/\(name)",
                fields: "name,capital,cca2,flag,flags"
            )
            
        case .all:
            return makeURL(
                path: "/v3.1/all",
                fields: "name"
            )
        }
    }
    
    private static func makeURL(path: String, fields: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "restcountries.com"
        components.path = path
        components.queryItems = [URLQueryItem(name: "fields", value: fields)]
        return components.url!
    }
}
