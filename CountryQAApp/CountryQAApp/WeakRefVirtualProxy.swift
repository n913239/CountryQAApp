//
//  WeakRefVirtualProxy.swift
//  CountryQAApp
//
//  Created by mike on 2026/6/26.
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
