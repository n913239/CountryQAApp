//
//  QuestionClassifier.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

public protocol QuestionClassifier {
    func classify(_ question: String) -> ClassifiedQuestion
}
