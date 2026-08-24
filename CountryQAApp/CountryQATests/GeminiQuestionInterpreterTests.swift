//
//  GeminiQuestionInterpreterTests.swift
//  CountryQATests
//
//  Created by mike on 2026/8/25.
//

import XCTest
@testable import CountryQA

final class GeminiQuestionInterpreterTests: XCTestCase {

    func test_interpret_postsQuestionToTheModelEndpointWithTheKey() async throws {
        let client = PostClientSpy(result: .success(response(intent: "unknown", argument: "")))
        let sut = makeSUT(client: client, apiKey: "a-key", model: "gemini-2.0-flash")

        _ = try await sut.interpret("What is the capital of Belgium?")

        XCTAssertEqual(client.requests.count, 1)
        let request = try XCTUnwrap(client.requests.first)
        XCTAssertEqual(request.url.absoluteString.contains("models/gemini-2.0-flash:generateContent"), true)
        XCTAssertEqual(request.url.query?.contains("key=a-key"), true)
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
        XCTAssertTrue(String(decoding: request.body, as: UTF8.self).contains("What is the capital of Belgium?"))
    }

    func test_interpret_deliversIntentFromStructuredResponse() async throws {
        let cases: [(intent: String, argument: String, expected: QuestionIntent)] = [
            ("capitalOf", "Belgium", .capitalOf("Belgium")),
            ("countriesStartingWith", "GR", .countriesStartingWith("GR")),
            ("isoCode", "Greece", .isoCode("Greece")),
            ("flagOf", "Brazil", .flagOf("Brazil")),
            ("unknown", "", .unknown)
        ]

        for aCase in cases {
            let client = PostClientSpy(result: .success(response(intent: aCase.intent, argument: aCase.argument)))
            let sut = makeSUT(client: client)

            let intent = try await sut.interpret("any question")

            XCTAssertEqual(intent, aCase.expected, "for model intent \(aCase.intent)")
        }
    }

    func test_interpret_unrecognizedIntentString_deliversUnknown() async throws {
        let client = PostClientSpy(result: .success(response(intent: "somethingElse", argument: "x")))
        let sut = makeSUT(client: client)

        let intent = try await sut.interpret("any question")

        XCTAssertEqual(intent, .unknown)
    }

    func test_interpret_onNon200Response_throwsInvalidResponse() async {
        let client = PostClientSpy(result: .success((Data("{}".utf8), httpResponse(400))))
        let sut = makeSUT(client: client)

        await assertThrows(sut, expected: .invalidResponse)
    }

    func test_interpret_onMalformedResponse_throwsInvalidResponse() async {
        let client = PostClientSpy(result: .success((Data("not json".utf8), httpResponse(200))))
        let sut = makeSUT(client: client)

        await assertThrows(sut, expected: .invalidResponse)
    }

    func test_interpret_onClientError_throwsConnectivity() async {
        let client = PostClientSpy(result: .failure(NSError(domain: "offline", code: 0)))
        let sut = makeSUT(client: client)

        await assertThrows(sut, expected: .connectivity)
    }

    // MARK: - Helpers

    private func makeSUT(
        client: PostClientSpy,
        apiKey: String = "any-key",
        model: String = "gemini-2.0-flash",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> GeminiQuestionInterpreter {
        let sut = GeminiQuestionInterpreter(client: client, apiKey: apiKey, model: model)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return sut
    }

    private func assertThrows(
        _ sut: GeminiQuestionInterpreter,
        expected: GeminiQuestionInterpreter.Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await sut.interpret("any question")
            XCTFail("Expected to throw \(expected)", file: file, line: line)
        } catch let error as GeminiQuestionInterpreter.Error {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected \(expected), got \(error)", file: file, line: line)
        }
    }

    private func response(intent: String, argument: String) -> (Data, HTTPURLResponse) {
        let inner = #"{"intent":"\#(intent)","argument":"\#(argument)"}"#
        let envelope: [String: Any] = [
            "candidates": [["content": ["parts": [["text": inner]]]]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: envelope)
        return (data, httpResponse(200))
    }

    private func httpResponse(_ statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://any.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

private final class PostClientSpy: HTTPPostClient {
    struct Request {
        let url: URL
        let body: Data
        let headers: [String: String]
    }

    private(set) var requests: [Request] = []
    private let result: Result<(Data, HTTPURLResponse), Error>

    init(result: Result<(Data, HTTPURLResponse), Error>) {
        self.result = result
    }

    func post(to url: URL, body: Data, headers: [String: String]) async throws -> (Data, HTTPURLResponse) {
        requests.append(Request(url: url, body: body, headers: headers))
        return try result.get()
    }
}
