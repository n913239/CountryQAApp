//
//  SmartQuestionClassifier.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public final class SmartQuestionClassifier: QuestionClassifier {

    private enum Topic: CaseIterable {
        case capital
        case isoCode
        case flag

        var keywords: [String] {
            switch self {
            case .capital: return ["capital"]
            case .isoCode: return ["iso", "code", "alpha", "cca"]
            case .flag: return ["flag"]
            }
        }

        func question(for country: String) -> ClassifiedQuestion {
            switch self {
            case .capital: return .capital(country: country)
            case .isoCode: return .isoCode(country: country)
            case .flag: return .flag(country: country)
            }
        }
    }

    private let startsWithKeywords = ["start", "begin"]

    private let articles: Set<String> = ["the", "a", "an"]
    private let noiseWords: Set<String> = ["country", "countries", "letter", "letters", "name", "names"]
    private let questionWords: Set<String> = [
        "what", "whats", "which", "who", "is", "are",
        "do", "you", "know", "can", "tell", "me", "show", "give", "please", "list"
    ]

    public init() {}

    public func classify(_ question: String) -> ClassifiedQuestion {
        let text = normalize(question)
        guard !text.isEmpty else { return .unknown }

        if let range = text.range(of: #"\bwith\b"#, options: .regularExpression) {
            let subject = String(text[text.startIndex..<range.lowerBound])
            if containsKeyword(in: subject, matching: startsWithKeywords, maxDistance: 2) {
                guard let letters = firstMeaningfulWord(in: String(text[range.upperBound...])) else {
                    return .unknown
                }
                return .countriesStartingWith(letters: letters.uppercased())
            }
        }

        if let range = text.range(of: #"\b(of|for)\b"#, options: .regularExpression) {
            let subject = String(text[text.startIndex..<range.lowerBound])
            if let topic = topic(inSubject: subject) {
                let country = stripEdgeNoise(String(text[range.upperBound...]))
                guard !country.isEmpty else { return .unknown }
                return topic.question(for: country)
            }
        }

        if let (topic, country) = topicAndCountryInTerseQuestion(text) {
            return topic.question(for: country)
        }

        return .unknown
    }

    // MARK: - Normalizing

    private func normalize(_ text: String) -> String {
        let separators = CharacterSet(charactersIn: "?!.,;:'\"’“”()-_/")
        return text
            .lowercased()
            .replacingOccurrences(of: "['’]s\\b", with: "", options: .regularExpression)
            .components(separatedBy: separators)
            .joined(separator: " ")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    // MARK: - "Which countries start with [Letters]?"

    private func firstMeaningfulWord(in text: String) -> String? {
        text
            .split(separator: " ")
            .map(String.init)
            .first { !articles.contains($0) && !noiseWords.contains($0) }
    }

    // MARK: - "... [topic] of/for [Country]"

    /// The subject never contains the country name, so keywords can be matched loosely here
    /// without a country such as "Benin" or "Cape Verde" ever colliding with one.
    private func topic(inSubject subject: String) -> Topic? {
        Topic.allCases.first { containsKeyword(in: subject, matching: $0.keywords, maxDistance: 2) }
    }

    // MARK: - "[Country] flag", "flag [Country]"

    private func topicAndCountryInTerseQuestion(_ text: String) -> (Topic, String)? {
        let words = text.split(separator: " ").map(String.init)

        for topic in Topic.allCases {
            guard words.contains(where: { isKeyword($0, in: topic.keywords, maxDistance: 1) }) else {
                continue
            }

            let country = stripEdgeNoise(
                words
                    .filter { !isKeyword($0, in: topic.keywords, maxDistance: 1) }
                    .filter { !questionWords.contains($0) }
                    .joined(separator: " ")
            )

            guard !country.isEmpty else { continue }
            return (topic, country)
        }

        return nil
    }

    // MARK: - Keyword matching

    /// A short keyword only tolerates a single typo, so "cape" (edit distance 2 from "code")
    /// can never be mistaken for one, while "falg" and "captial" still are.
    private func isKeyword(_ word: String, in keywords: [String], maxDistance: Int) -> Bool {
        keywords.contains { keyword in
            if word == keyword || word.hasPrefix(keyword) { return true }
            guard keyword.count >= 4 else { return false }
            return editDistance(word, keyword) <= maxDistance
        }
    }

    private func containsKeyword(in text: String, matching keywords: [String], maxDistance: Int) -> Bool {
        text
            .split(separator: " ")
            .map(String.init)
            .contains { isKeyword($0, in: keywords, maxDistance: maxDistance) }
    }

    // MARK: - Country cleanup

    private func stripEdgeNoise(_ phrase: String) -> String {
        var words = phrase.split(separator: " ").map(String.init)

        while let first = words.first, articles.contains(first) || noiseWords.contains(first) {
            words.removeFirst()
        }
        while let last = words.last, articles.contains(last) || noiseWords.contains(last) {
            words.removeLast()
        }

        return words.joined(separator: " ")
    }
}
