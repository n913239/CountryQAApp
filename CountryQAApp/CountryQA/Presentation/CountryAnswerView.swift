//
//  CountryAnswerView.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

@MainActor
public protocol CountryAnswerView {
    func display(_ viewModel: CountryAnswerViewModel)
}
