//
//  CountryInfo.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public struct CountryInfo: Equatable {
    public let name: String
    public let capital: String?
    public let cca2: String?
    public let flag: String?
    public let flagImageURL: URL?
    public let alternativeNames: [String]

    public init(
        name: String,
        capital: String?,
        cca2: String?,
        flag: String?,
        flagImageURL: URL?,
        alternativeNames: [String] = []
    ) {
        self.name = name
        self.capital = capital
        self.cca2 = cca2
        self.flag = flag
        self.flagImageURL = flagImageURL
        self.alternativeNames = alternativeNames
    }
}
