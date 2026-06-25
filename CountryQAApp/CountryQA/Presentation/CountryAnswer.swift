//
//  CountryAnswer.swift
//  CountryQA
//
//  Created by mike on 2026/6/25.
//

import Foundation

public enum CountryAnswer: Equatable {
    case capital(country: String, capital: String)
    case countriesStartingWith(letters: String, countries: [String])
    case isoCode(country: String, code: String)
    case flag(country: String, flagEmoji: String, flagImageURL: URL?)
    case unknown
    case countryNotFound(query: String)
    case loadingFailed
}
