//
//  GeminiQuestionInterpreter.swift
//  CountryQA
//
//  Created by mike on 2026/8/25.
//

import Foundation

/// Interprets a free-text question into a `QuestionIntent` using Google's Gemini model.
/// The model is asked to return structured JSON (`responseSchema`), so the reply is parsed
/// directly into an intent - no keyword or regular-expression matching. The model only
/// interprets the question; the facts themselves are always answered from the country dataset.
public final class GeminiQuestionInterpreter: QuestionInterpreter {
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidResponse
    }

    private let client: HTTPPostClient
    private let apiKey: String
    private let model: String
    private let baseURL: URL

    public init(
        client: HTTPPostClient,
        apiKey: String,
        model: String = "gemini-flash-lite-latest",
        baseURL: URL = URL(string: "https://generativelanguage.googleapis.com/v1beta")!
    ) {
        self.client = client
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
    }

    public func interpret(_ text: String) async throws -> QuestionIntent {
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.post(
                to: endpointURL(),
                body: try requestBody(for: text),
                headers: ["Content-Type": "application/json"]
            )
        } catch {
            throw Error.connectivity
        }
        return try Self.intent(from: data, response: response)
    }

    // MARK: - Request

    private func endpointURL() -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("models/\(model):generateContent"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        return components.url!
    }

    private func requestBody(for question: String) throws -> Data {
        let request = RequestDTO(
            contents: [.init(parts: [.init(text: Self.prompt(for: question))])],
            generationConfig: .init(responseMimeType: "application/json", responseSchema: .intent)
        )
        return try JSONEncoder().encode(request)
    }

    private static func prompt(for question: String) -> String {
        """
        You classify a user's question about countries into exactly one intent and extract its argument.

        Intents:
        - capitalOf: the capital city of a country. argument = the country name.
        - countriesStartingWith: which countries begin with some letters. argument = the letters only.
        - isoCode: the ISO alpha-2 code of a country. argument = the country name.
        - flagOf: the flag of a country. argument = the country name.
        - unknown: anything that is none of the above. argument = an empty string.

        Keep the country name or letters exactly as written; do not correct spelling.

        Question: "\(question)"
        """
    }

    // MARK: - Response

    private static func intent(from data: Data, response: HTTPURLResponse) throws -> QuestionIntent {
        guard response.statusCode == 200,
              let envelope = try? JSONDecoder().decode(ResponseDTO.self, from: data),
              let json = envelope.candidates.first?.content.parts.first?.text,
              let payload = try? JSONDecoder().decode(IntentDTO.self, from: Data(json.utf8)) else {
            throw Error.invalidResponse
        }

        switch payload.intent {
        case "capitalOf": return .capitalOf(payload.argument)
        case "countriesStartingWith": return .countriesStartingWith(payload.argument)
        case "isoCode": return .isoCode(payload.argument)
        case "flagOf": return .flagOf(payload.argument)
        default: return .unknown
        }
    }
}

// MARK: - Wire format

private struct RequestDTO: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    struct Content: Encodable { let parts: [Part] }
    struct Part: Encodable { let text: String }

    struct GenerationConfig: Encodable {
        let responseMimeType: String
        let responseSchema: Schema
    }

    struct Schema: Encodable {
        let type: String
        let properties: Properties
        let required: [String]

        static let intent = Schema(
            type: "OBJECT",
            properties: Properties(
                intent: .init(type: "STRING", enum: ["capitalOf", "countriesStartingWith", "isoCode", "flagOf", "unknown"]),
                argument: .init(type: "STRING", enum: nil)
            ),
            required: ["intent", "argument"]
        )

        struct Properties: Encodable {
            let intent: Field
            let argument: Field
        }

        struct Field: Encodable {
            let type: String
            let `enum`: [String]?
        }
    }
}

private struct ResponseDTO: Decodable {
    let candidates: [Candidate]

    struct Candidate: Decodable { let content: Content }
    struct Content: Decodable { let parts: [Part] }
    struct Part: Decodable { let text: String }
}

private struct IntentDTO: Decodable {
    let intent: String
    let argument: String
}
