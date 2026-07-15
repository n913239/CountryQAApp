//
//  CountryQAFactory.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public enum CountryQAFactory {
    public static func makeUseCase(
        httpClient: HTTPClient,
        url: URL = CountriesDatasetEndpoint.url
    ) -> CountryQAUseCase {
        let remoteLoader = RemoteCountryInfoLoader(client: httpClient, url: url)
        let cachingLoader = CachingCountryInfoLoader(decoratee: remoteLoader)
        return CountryQAUseCase(
            classifier: SmartQuestionClassifier(),
            loader: cachingLoader
        )
    }
}
