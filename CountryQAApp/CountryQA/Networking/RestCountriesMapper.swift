//
//  RestCountriesMapper.swift
//  CountryQA
//
//  Created by mike on 2026/6/24.
//

import Foundation

public enum RestCountriesMapper {
    private struct Root: Decodable {
        let name: Name
        let capital: [String]?
        let cca2: String?
        let flag: String?
        let flags: Flags?
        
        struct Name: Decodable { let common: String }
        struct Flags: Decodable { let png: String? }
    }
    
    public enum Error: Swift.Error { case invalidData }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CountryInfo] {
        guard response.statusCode == 200,
              let roots = try? JSONDecoder().decode([Root].self, from: data) else {
            throw Error.invalidData
        }
        return roots.map { root in
            CountryInfo(
                name: root.name.common,
                capital: root.capital?.first,
                cca2: root.cca2,
                flag: root.flag,
                flagImageURL: root.flags?.png.flatMap(URL.init(string:))
            )
        }
    }
}
