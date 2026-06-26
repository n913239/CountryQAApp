//
//  ChatViewControllerSnapshotTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/26.
//

import XCTest
import CountryQA
@testable import CountryQAApp

@MainActor
final class ChatViewControllerSnapshotTests: XCTestCase {
    
    func test_capitalAnswer_light() {
        let sut = makeSUT()
        
        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_CAPITAL_light")
    }
    
    func test_capitalAnswer_dark() {
        let sut = makeSUT()
        
        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CHAT_CAPITAL_dark")
    }
    
    func test_errorWithRetry_light() {
        let sut = makeSUT()
        
        sut.display(CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_ERROR_RETRY_light")
    }
    
    func test_errorWithRetry_dark() {
        let sut = makeSUT()
        
        sut.display(CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CHAT_ERROR_RETRY_dark")
    }
    
    func test_unknownAnswer_light() {
        let sut = makeSUT()
        
        sut.display(CountryAnswerViewModel(message: "I don't understand that question. Try asking about a country's capital, ISO code, flag, or which countries start with certain letters."))
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_UNKNOWN_light")
    }
    
    func test_conversation_extraExtraExtraLargeContentSize() {
        let sut = makeSUT()
        
        sut.simulateUserSends("What is the capital of Belgium?")
        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))

        // Looser tolerance: the very large glyphs at this content size produce many
        // antialiased edge pixels that differ slightly across GPU generations (dev vs CI).
        assert(
            snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .accessibilityExtraExtraExtraLarge)),
            named: "CHAT_CONVERSATION_XXXL",
            precision: 0.94,
            perChannelTolerance: 48
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ChatViewController {
        let sut = ChatViewController()
        sut.loadViewIfNeeded()
        return sut
    }
}
