//
//  CountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public protocol CountryInfoLoader {
    func load(query: CountryQuery) async throws -> [CountryInfo]
}

public enum CountryQuery: Equatable {
    case searchByName(String)
    case all
}
