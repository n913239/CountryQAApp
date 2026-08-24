//
//  QuestionInterpreter.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

public protocol QuestionInterpreter {
    func interpret(_ text: String) async throws -> QuestionIntent
}
