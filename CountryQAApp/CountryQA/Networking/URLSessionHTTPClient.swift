//
//  URLSessionHTTPClient.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient, HTTPPostClient {
    public struct UnexpectedValuesRepresentation: Error {}

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        try httpResponse(for: try await session.data(from: url))
    }

    public func post(to url: URL, body: Data, headers: [String: String]) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return try httpResponse(for: try await session.data(for: request))
    }

    private func httpResponse(for result: (Data, URLResponse)) throws -> (Data, HTTPURLResponse) {
        guard let httpResponse = result.1 as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        return (result.0, httpResponse)
    }
}
