//
//  CountryMatcher.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public enum CountryMatcher {

    public static func match(_ query: String, in countries: [CountryInfo]) -> CountryInfo? {
        let query = normalize(query)
        guard !query.isEmpty else { return nil }

        if let exact = countries.first(where: { names(of: $0).contains(query) }) {
            return exact
        }

        if let code = countries.first(where: { normalize($0.cca2 ?? "") == query }), query.count == 2 {
            return code
        }

        if let prefixed = uniqueCountry(in: countries, where: { $0.hasPrefix(query) }) {
            return prefixed
        }

        return closestCountry(to: query, in: countries)
    }

    // MARK: - Helpers

    private static func names(of country: CountryInfo) -> [String] {
        ([country.name] + country.alternativeNames).map(normalize)
    }

    private static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func uniqueCountry(
        in countries: [CountryInfo],
        where matches: (String) -> Bool
    ) -> CountryInfo? {
        let found = countries.filter { names(of: $0).contains(where: matches) }
        return found.count == 1 ? found.first : nil
    }

    /// Tolerates a typo of roughly one character per four, so "belgim" finds Belgium
    /// while a genuinely unknown country is still reported as not found.
    private static func closestCountry(to query: String, in countries: [CountryInfo]) -> CountryInfo? {
        let allowedDistance = max(1, query.count / 4)

        var best: (country: CountryInfo, distance: Int)?

        for country in countries {
            for name in names(of: country) {
                let distance = editDistance(name, query)
                guard distance <= allowedDistance else { continue }

                if best == nil || distance < best!.distance {
                    best = (country, distance)
                }
            }
        }

        return best?.country
    }
}
