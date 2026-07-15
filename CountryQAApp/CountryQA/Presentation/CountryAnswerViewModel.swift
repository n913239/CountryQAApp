//
//  CountryAnswerViewModel.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public struct CountryAnswerViewModel: Equatable {
    public let message: String
    public let flagEmoji: String?
    public let flagImageURL: URL?
    public let showsRetry: Bool

    public init(
        message: String,
        flagEmoji: String? = nil,
        flagImageURL: URL? = nil,
        showsRetry: Bool = false
    ) {
        self.message = message
        self.flagEmoji = flagEmoji
        self.flagImageURL = flagImageURL
        self.showsRetry = showsRetry
    }
}
