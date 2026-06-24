//
//  SmartQuestionClassifier.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public final class SmartQuestionClassifier: QuestionClassifier {
    
    private struct Rule {
        let keywords: [String]
        let build: (String) -> ClassifiedQuestion
    }
    
    private let maxDistance = 2
    
    // 句首問句填充詞（逐一剝除，longest-ish 在前）
    private let leadingFillers = [
        "what is", "what's", "whats", "what are", "what",
        "can you tell me", "do you know", "tell me", "show me", "give me",
        "which", "please", "list", "name", "the", "a", "an"
    ]
    
    public init() {}
    
    public func classify(_ question: String) -> ClassifiedQuestion {
        let text = stripLeadingFillers(clean(question))
        let words = text.split(separator: " ").map(String.init)
        
        // countriesStartingWith 先判（擷取邏輯與 country 不同）
        if containsKeyword(words, matching: ["start", "begin"]) {
            guard let letters = extractLetters(from: text) else { return .unknown }
            return .countriesStartingWith(letters: letters.uppercased())
        }
        
        let rules: [Rule] = [
            Rule(keywords: ["capital"]) { .capital(country: $0) },
            Rule(keywords: ["code", "iso", "alpha"]) { .isoCode(country: $0) },
            Rule(keywords: ["flag"]) { .flag(country: $0) },
        ]
        
        for rule in rules where containsKeyword(words, matching: rule.keywords) {
            guard let country = extractCountry(from: text, keywords: rule.keywords) else { return .unknown }
            return rule.build(country)
        }
        
        return .unknown
    }
    
    // MARK: - Cleaning
    
    private func clean(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    private func stripLeadingFillers(_ text: String) -> String {
        var result = text
        var changed = true
        while changed {
            changed = false
            for filler in leadingFillers {
                if result == filler {
                    result = ""
                    changed = true
                    break
                }
                if result.hasPrefix(filler + " ") {
                    result = String(result.dropFirst(filler.count + 1))
                    changed = true
                    break
                }
            }
        }
        return result
    }
    
    // MARK: - Keyword matching (fuzzy)
    
    private func isKeyword(_ word: String, in keywords: [String]) -> Bool {
        keywords.contains { keyword in
            word == keyword
            || word.hasPrefix(keyword)
            || (keyword.count >= 4 && levenshteinDistance(word, keyword) <= maxDistance)
        }
    }
    
    private func containsKeyword(_ words: [String], matching keywords: [String]) -> Bool {
        words.contains { isKeyword($0, in: keywords) }
    }
    
    // MARK: - Country extraction
    
    private func extractCountry(from text: String, keywords: [String]) -> String? {
        // 1) 介係詞："... of/for <country>"
        if let prep = firstMatch(in: text, pattern: "\\b(?:of|for)\\s+(.+)$") {
            return nonEmpty(cleanCountry(prep))
        }
        // 2) 所有格："<country>'s ..." → 取 's 前完整片語（含多字、連字號）
        if let poss = firstMatch(in: text, pattern: "^([a-z -]+?)'s\\b") {
            return nonEmpty(cleanCountry(poss))
        }
        // 3) 退路：移除 keyword token，其餘當國名（terse: "brazil flag"）
        let remaining = text.split(separator: " ").map(String.init)
            .filter { !isKeyword($0, in: keywords) }
        return nonEmpty(cleanCountry(remaining.joined(separator: " ")))
    }
    
    private func cleanCountry(_ phrase: String) -> String {
        var tokens = phrase.split(separator: " ").map(String.init)
        // 只去「頭尾」雜詞（中間的 of 如 "republic of korea" 保留）
        let noise: Set<String> = ["the", "a", "an", "of", "for", "country", "countries"]
        while let first = tokens.first, noise.contains(first) { tokens.removeFirst() }
        while let last = tokens.last, noise.contains(last) { tokens.removeLast() }
        return tokens.joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
    
    private func extractLetters(from text: String) -> String? {
        guard let after = firstMatch(in: text, pattern: "\\bwith\\s+(.+)$") else { return nil }
        var tokens = after.split(separator: " ").map(String.init)
        let drop: Set<String> = ["the", "letter", "letters"]
        while let first = tokens.first, drop.contains(first) { tokens.removeFirst() }
        return tokens.first
    }
    
    // MARK: - Helpers
    
    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return String(text[range]).trimmingCharacters(in: .whitespaces)
    }
    
    private func nonEmpty(_ s: String) -> String? {
        s.isEmpty ? nil : s
    }
}
