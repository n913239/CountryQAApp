//
//  CountryAnswerViewModel.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public struct CountryAnswerViewModel: Equatable {
    public let message: String
    public let flagEmoji: String?
    public let flagImageURL: URL?

    /// The question to re-ask when the user taps retry. A value means the bubble was an error
    /// and offers a retry that re-asks *this* question - never whatever was asked most recently.
    public let retryQuestion: String?

    public var showsRetry: Bool { retryQuestion != nil }

    public init(
        message: String,
        flagEmoji: String? = nil,
        flagImageURL: URL? = nil,
        retryQuestion: String? = nil
    ) {
        self.message = message
        self.flagEmoji = flagEmoji
        self.flagImageURL = flagImageURL
        self.retryQuestion = retryQuestion
    }
}
