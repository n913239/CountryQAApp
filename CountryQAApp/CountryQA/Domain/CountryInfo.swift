//
//  CountryInfo.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public struct CountryInfo: Equatable {
    public let name: String
    public let capital: String?
    public let cca2: String?
    public let flag: String?
    public let flagImageURL: URL?
    
    public init(name: String, capital: String?, cca2: String?, flag: String?, flagImageURL: URL?) {
        self.name = name
        self.capital = capital
        self.cca2 = cca2
        self.flag = flag
        self.flagImageURL = flagImageURL
    }
}
