//
//  CountryQALocalizationTests.swift
//  CountryQATests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA

@MainActor
final class CountryQALocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "CountryQA"
        let bundle = Bundle(for: CountryAnswerPresenter.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
