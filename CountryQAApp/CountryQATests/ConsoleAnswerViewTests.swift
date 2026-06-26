//
//  ConsoleAnswerViewTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/26.
//

import XCTest
import CountryQA

@MainActor
final class ConsoleAnswerViewTests: XCTestCase {
    
    func test_display_outputsMessage() {
        var output = [String]()
        let sut = ConsoleAnswerView { output.append($0) }
        
        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))
        
        XCTAssertEqual(output, ["The capital of Belgium is Brussels."])
    }
    
    func test_display_withFlagEmoji_prependsFlag() {
        var output = [String]()
        let sut = ConsoleAnswerView { output.append($0) }
        
        sut.display(CountryAnswerViewModel(message: "The flag of Brazil is shown below.", flagEmoji: "🇧🇷"))
        
        XCTAssertEqual(output, ["🇧🇷 The flag of Brazil is shown below."])
    }
    
    func test_display_whenRetryShown_appendsRetryHint() {
        var output = [String]()
        let sut = ConsoleAnswerView { output.append($0) }
        
        sut.display(CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true))
        
        XCTAssertEqual(output, [
            "Something went wrong loading the answer. Please try again.",
            "Type 'retry' to try again."
        ])
    }
}
