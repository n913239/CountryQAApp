//
//  CountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public protocol CountryInfoLoader {
    func load() async throws -> [CountryInfo]
}
