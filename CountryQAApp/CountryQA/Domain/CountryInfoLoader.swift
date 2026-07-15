//
//  CountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public protocol CountryInfoLoader {
    func load() async throws -> [CountryInfo]
}
