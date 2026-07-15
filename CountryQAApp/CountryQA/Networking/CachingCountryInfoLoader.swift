//
//  CachingCountryInfoLoader.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

/// The dataset is a single 1.4 MB document that describes every country, so it is fetched once
/// and reused for every later question. A failed load is not cached, so the next question retries.
public actor CachingCountryInfoLoader: CountryInfoLoader {
    private let decoratee: CountryInfoLoader
    private var cached: [CountryInfo]?
    private var loadInProgress: Task<[CountryInfo], Swift.Error>?

    public init(decoratee: CountryInfoLoader) {
        self.decoratee = decoratee
    }

    public func load() async throws -> [CountryInfo] {
        if let cached {
            return cached
        }

        if let loadInProgress {
            return try await loadInProgress.value
        }

        let task = Task { [decoratee] in
            try await decoratee.load()
        }
        loadInProgress = task

        do {
            let countries = try await task.value
            cached = countries
            loadInProgress = nil
            return countries
        } catch {
            loadInProgress = nil
            throw error
        }
    }
}
