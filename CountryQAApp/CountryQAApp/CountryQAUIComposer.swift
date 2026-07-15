//
//  CountryQAUIComposer.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/16.
//

import UIKit
import CountryQA

@MainActor
enum CountryQAUIComposer {
    static func compose(httpClient: HTTPClient) -> ChatViewController {
        let useCase = CountryQAFactory.makeUseCase(httpClient: httpClient)
        let viewController = ChatViewController()
        viewController.imageLoader = { url in
            try? await httpClient.get(from: url).0
        }

        let proxy = WeakRefVirtualProxy(viewController)
        let presenter = CountryAnswerPresenter(view: proxy)
        let adapter = CountryQAPresentationAdapter(useCase: useCase)
        adapter.presenter = presenter

        viewController.onAsk = { [adapter] question in adapter.ask(question) }
        return viewController
    }
}
