//
//  ConsoleAnswerView.swift
//  CountryQA
//
//  Created by mike on 2026/6/26.
//

import Foundation

@MainActor
public final class ConsoleAnswerView: CountryAnswerView {
    private let output: (String) -> Void
    
    public init(output: @escaping (String) -> Void) {
        self.output = output
    }
    
    public func display(_ viewModel: CountryAnswerViewModel) {
        if let flagEmoji = viewModel.flagEmoji {
            output("\(flagEmoji) \(viewModel.message)")
        } else {
            output(viewModel.message)
        }
        if viewModel.showsRetry {
            output("Type 'retry' to try again.")
        }
    }
}
