//
//  ClassifiedQuestion.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

public enum ClassifiedQuestion: Equatable {
    case capital(country: String)
    case countriesStartingWith(letters: String)
    case isoCode(country: String)
    case flag(country: String)
    case unknown
}
