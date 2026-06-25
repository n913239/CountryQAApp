//
//  CountryQAFactory.swift
//  CountryQA
//
//  Created by mike on 2026/6/26.
//

import Foundation

public enum CountryQAFactory {
    public static func makeUseCase(httpClient: HTTPClient) -> CountryQAUseCase {
        let loader = RemoteCountryInfoLoader(client: httpClient)
        let classifier = SmartQuestionClassifier()
        return CountryQAUseCase(classifier: classifier, loader: loader)
    }
}
