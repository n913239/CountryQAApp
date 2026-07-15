//
//  WeakRefVirtualProxy.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/16.
//

import CountryQA

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: CountryAnswerView where T: CountryAnswerView {
    func display(_ viewModel: CountryAnswerViewModel) {
        object?.display(viewModel)
    }
}
