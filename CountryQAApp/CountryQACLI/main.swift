//
//  main.swift
//  CountryQACLI
//
//  Created by mike on 2026/8/24.
//

import Foundation
import CountryQA

setvbuf(stdout, nil, _IOLBF, 0)

let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
let interpreter = CountryQAFactory.makeGeminiInterpreter(httpClient: httpClient, apiKey: apiKey)

let console = CountryQACLIComposer.compose(httpClient: httpClient, interpreter: interpreter)

console.greet()

while true {
    print("> ", terminator: "")

    guard let line = readLine() else { break }
    if await console.handle(line) == .finished { break }

    print()
}
