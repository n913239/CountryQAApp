//
//  CountryAnswerView.swift
//  CountryQA
//
//  Created by mike on 2026/6/25.
//

import Foundation

@MainActor
public protocol CountryAnswerView {
    func display(_ viewModel: CountryAnswerViewModel)
}
