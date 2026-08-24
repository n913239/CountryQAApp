//
//  QuestionIntent.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

public enum QuestionIntent: Equatable {
    case capitalOf(String)
    case countriesStartingWith(String)
    case isoCode(String)
    case flagOf(String)
    case unknown
}
