//
//  CountryQAUIComposer.swift
//  CountryQAApp
//
//  Created by mike on 2026/8/26.
//

import UIKit
import CountryQA

@MainActor
enum CountryQAUIComposer {
    static func compose(httpClient: HTTPClient, interpreter: QuestionInterpreter) -> ChatViewController {
        let useCase = CountryQAFactory.makeUseCase(interpreter: interpreter, httpClient: httpClient)
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
