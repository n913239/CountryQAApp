//
//  CountryQAUseCase.swift
//  CountryQA
//
//  Created by mike on 2026/6/25.
//

import Foundation

public final class CountryQAUseCase {
    private let classifier: QuestionClassifier
    private let loader: CountryInfoLoader
    
    public init(classifier: QuestionClassifier, loader: CountryInfoLoader) {
        self.classifier = classifier
        self.loader = loader
    }
    
    public func answer(_ question: String) async -> CountryAnswer {
        let classified = classifier.classify(question)
        
        do {
            switch classified {
            case let .capital(country):
                guard let info = try await resolveCountry(country), let capital = info.capital else {
                    return .countryNotFound(query: country)
                }
                return .capital(country: info.name, capital: capital)
                
            case let .countriesStartingWith(letters):
                let prefix = letters.uppercased()
                let countries = try await loader.load(query: .all)
                let matching = countries
                    .filter { $0.name.uppercased().hasPrefix(prefix) }
                    .map(\.name)
                return .countriesStartingWith(letters: prefix, countries: matching)
                
            case let .isoCode(country):
                guard let info = try await resolveCountry(country), let code = info.cca2 else {
                    return .countryNotFound(query: country)
                }
                return .isoCode(country: info.name, code: code)
                
            case let .flag(country):
                guard let info = try await resolveCountry(country), let flag = info.flag else {
                    return .countryNotFound(query: country)
                }
                return .flag(country: info.name, flagEmoji: flag, flagImageURL: info.flagImageURL)
                
            case .unknown:
                return .unknown
            }
        } catch {
            return .loadingFailed
        }
    }
    
    // MARK: - Fuzzy country resolution（題目 "or even misspelled!"）
    
    private func resolveCountry(_ name: String) async throws -> CountryInfo? {
        // 1) 直查國名（拼對就一次命中；錯誤吞掉，往 fuzzy 走）
        if let results = try? await loader.load(query: .searchByName(name)), let first = results.first {
            return first
        }
        
        // 2) Fallback：抓全清單，用 Levenshtein 找最近（閾值 ≤ 3）
        let all = try await loader.load(query: .all)
        let lowered = name.lowercased()
        let closest = all.min {
            levenshteinDistance($0.name.lowercased(), lowered) < levenshteinDistance($1.name.lowercased(), lowered)
        }
        guard let closest, levenshteinDistance(closest.name.lowercased(), lowered) <= 3 else {
            return nil
        }
        
        // 3) 用修正後名字重查，拿完整欄位（capital/cca2/flag…）
        let corrected = try await loader.load(query: .searchByName(closest.name))
        return corrected.first
    }
}
