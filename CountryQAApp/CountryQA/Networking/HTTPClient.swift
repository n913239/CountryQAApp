//
//  HTTPClient.swift
//  CountryQA
//
//  Created by mike on 2026/7/16.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
