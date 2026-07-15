//
//  QuestionClassifier.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

public protocol QuestionClassifier {
    func classify(_ question: String) -> ClassifiedQuestion
}
