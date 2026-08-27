//
//  CountriesDatasetEndpoint.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

/// The challenge suggests restcountries.com, but its keyless versions (v1 to v4) are deprecated -
/// a request now redirects to a payload reporting the API is gone instead of returning countries -
/// and the replacement version requires an API key, which cannot ship in a public repository. This
/// reads the open dataset restcountries.com is itself built from - the same countries, the same
/// fields, no key. See README.md.
public enum CountriesDatasetEndpoint {
    public static let url = URL(string: "https://raw.githubusercontent.com/mledoze/countries/master/countries.json")!
}
