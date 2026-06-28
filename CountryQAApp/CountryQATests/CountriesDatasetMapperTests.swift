//
//  CountriesDatasetMapperTests.swift
//  CountryQATests
//
//  Created by mike on 2026/6/28.
//

import XCTest
import CountryQA

final class CountriesDatasetMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() {
        let data = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            XCTAssertThrowsError(
                try CountriesDatasetMapper.map(data, from: HTTPURLResponse(statusCode: code)),
                "Expected error for status code \(code)"
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid".utf8)
        
        XCTAssertThrowsError(
            try CountriesDatasetMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversEmptyListOn200HTTPResponseWithEmptyJSON() throws {
        let result = try CountriesDatasetMapper.map(makeItemsJSON([]), from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_derivesFlagImageURLFromCCA2() throws {
        let item = makeCountryItem(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪")
        
        let result = try CountriesDatasetMapper.map(makeItemsJSON([item.json]), from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item.model])
    }
    
    func test_map_deliversMultipleCountryInfo() throws {
        let item1 = makeCountryItem(name: "Belgium", capital: "Brussels", cca2: "BE", flag: "🇧🇪")
        let item2 = makeCountryItem(name: "Brazil", capital: "Brasília", cca2: "BR", flag: "🇧🇷")
        
        let result = try CountriesDatasetMapper.map(makeItemsJSON([item1.json, item2.json]), from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    
    private func makeCountryItem(name: String, capital: String?, cca2: String?, flag: String?) -> (model: CountryInfo, json: [String: Any]) {
        let model = CountryInfo(
            name: name,
            capital: capital,
            cca2: cca2,
            flag: flag,
            flagImageURL: cca2.flatMap { URL(string: "https://flagcdn.com/w320/\($0.lowercased()).png") }
        )
        
        var json: [String: Any] = ["name": ["common": name, "official": name]]
        if let capital { json["capital"] = [capital] }
        if let cca2 { json["cca2"] = cca2 }
        if let flag { json["flag"] = flag }
        
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
