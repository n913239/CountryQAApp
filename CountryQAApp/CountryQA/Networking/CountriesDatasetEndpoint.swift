//
//  CountriesDatasetEndpoint.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

/// The challenge suggests restcountries.com, but every one of its keyless versions (v1 to v4) has
/// been withdrawn and the current API answers `401 Authorization key required`. Shipping a key in a
/// public repository is not an option, so this reads the open dataset restcountries.com is itself
/// built from - the same countries, the same fields, no key. See README.md.
public enum CountriesDatasetEndpoint {
    public static let url = URL(string: "https://raw.githubusercontent.com/mledoze/countries/master/countries.json")!
}
