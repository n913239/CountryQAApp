//
//  HTTPPostClient.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public protocol HTTPPostClient {
    func post(to url: URL, body: Data, headers: [String: String]) async throws -> (Data, HTTPURLResponse)
}
