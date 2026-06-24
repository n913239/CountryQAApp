//
//  RestCountriesMapperTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/24.
//

import XCTest
import CountryQA

final class RestCountriesMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() {
        let data = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            XCTAssertThrowsError(
                try RestCountriesMapper.map(data, from: HTTPURLResponse(statusCode: code)),
                "Expected error for status code \(code)"
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid".utf8)
        
        XCTAssertThrowsError(
            try RestCountriesMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversEmptyListOn200HTTPResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemsJSON([])
        
        let result = try RestCountriesMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversOneCountryInfoOn200HTTPResponse() throws {
        let item = makeCountryItem(
            name: "Belgium",
            capital: "Brussels",
            cca2: "BE",
            flag: "🇧🇪",
            flagPNG: "https://flagcdn.com/w320/be.png"
        )
        
        let json = makeItemsJSON([item.json])
        let result = try RestCountriesMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item.model])
    }
    
    func test_map_deliversMultipleCountryInfoOn200HTTPResponse() throws {
        let item1 = makeCountryItem(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪", flagPNG: "https://flagcdn.com/w320/be.png")
        let item2 = makeCountryItem(name: "Brazil", capital: "Brasília", cca2: "BR", flag: "🇧🇷", flagPNG: "https://flagcdn.com/w320/br.png")
        
        let json = makeItemsJSON([item1.json, item2.json])
        let result = try RestCountriesMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    
    private func makeCountryItem(
        name: String,
        capital: String?,
        cca2: String?,
        flag: String?,
        flagPNG: String?
    ) -> (model: CountryInfo, json: [String: Any]) {
        let model = CountryInfo(
            name: name,
            capital: capital,
            cca2: cca2,
            flag: flag,
            flagImageURL: flagPNG.flatMap(URL.init(string:))
        )
        
        var json: [String: Any] = [
            "name": ["common": name, "official": name]
        ]
        if let capital { json["capital"] = [capital] }
        if let cca2 { json["cca2"] = cca2 }
        if let flag { json["flag"] = flag }
        if let flagPNG { json["flags"] = ["png": flagPNG, "svg": ""] }
        
        return (model, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        try! JSONSerialization.data(withJSONObject: items)
    }
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: URL(string: "https://any-url.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
