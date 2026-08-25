//
//  CountryQAFactory.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public enum CountryQAFactory {
    public static func makeUseCase(
        interpreter: QuestionInterpreter,
        httpClient: HTTPClient,
        url: URL = CountriesDatasetEndpoint.url
    ) -> CountryQAUseCase {
        let remoteLoader = RemoteCountryInfoLoader(client: httpClient, url: url)
        let cachingLoader = CachingCountryInfoLoader(decoratee: remoteLoader)
        return CountryQAUseCase(interpreter: interpreter, loader: cachingLoader)
    }

    public static func makeGeminiInterpreter(httpClient: HTTPPostClient, apiKey: String) -> QuestionInterpreter {
        GeminiQuestionInterpreter(client: httpClient, apiKey: apiKey)
    }
}
