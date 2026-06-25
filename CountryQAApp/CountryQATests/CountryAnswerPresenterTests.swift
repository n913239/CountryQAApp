//
//  CountryAnswerPresenterTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/25.
//

import XCTest
@testable import CountryQA

@MainActor
final class CountryAnswerPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty, "Expected no view messages on init")
    }
    
    func test_present_capital_displaysCapitalMessage() {
        let (sut, spy) = makeSUT()
        
        sut.present(.capital(country: "Belgium", capital: "Brussels"))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "The capital of Belgium is Brussels.")
        ])
    }
    
    func test_present_countriesStartingWith_displaysJoinedList() {
        let (sut, spy) = makeSUT()
        
        sut.present(.countriesStartingWith(letters: "CH", countries: ["Chad", "Chile", "China"]))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "Countries starting with CH: Chad, Chile, China.")
        ])
    }
    
    func test_present_countriesStartingWith_empty_displaysNoneMessage() {
        let (sut, spy) = makeSUT()
        
        sut.present(.countriesStartingWith(letters: "ZZ", countries: []))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "No countries found starting with ZZ.")
        ])
    }
    
    func test_present_isoCode_displaysCodeMessage() {
        let (sut, spy) = makeSUT()
        
        sut.present(.isoCode(country: "Greece", code: "GR"))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "The ISO alpha-2 country code for Greece is GR.")
        ])
    }
    
    func test_present_flag_displaysFlagWithEmojiAndImageURL() {
        let (sut, spy) = makeSUT()
        let url = URL(string: "https://flagcdn.com/w320/br.png")
        
        sut.present(.flag(country: "Brazil", flagEmoji: "🇧🇷", flagImageURL: url))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "The flag of Brazil is 🇧🇷", flagEmoji: "🇧🇷", flagImageURL: url)
        ])
    }
    
    func test_present_unknown_displaysGuidanceMessage() {
        let (sut, spy) = makeSUT()
        
        sut.present(.unknown)
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "I don't understand that question. Try asking about a country's capital, ISO code, flag, or which countries start with certain letters.")
        ])
    }
    
    func test_present_countryNotFound_displaysNotFoundMessageWithoutRetry() {
        let (sut, spy) = makeSUT()
        
        sut.present(.countryNotFound(query: "Atlantis"))
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "Sorry, I couldn't find a country called \"Atlantis\".")
        ])
        XCTAssertEqual(spy.messages.first?.showsRetry, false)
    }
    
    func test_present_loadingFailed_displaysErrorMessageWithRetry() {
        let (sut, spy) = makeSUT()
        
        sut.present(.loadingFailed)
        
        XCTAssertEqual(spy.messages, [
            CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true)
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (CountryAnswerPresenter, ViewSpy) {
        let spy = ViewSpy()
        let sut = CountryAnswerPresenter(view: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }
    
    @MainActor
    private final class ViewSpy: CountryAnswerView {
        private(set) var messages: [CountryAnswerViewModel] = []
        
        func display(_ viewModel: CountryAnswerViewModel) {
            messages.append(viewModel)
        }
    }
}
