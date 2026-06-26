//
//  main.swift
//  CountryQACLI
//
//  Created by mike on 2026/6/24.
//

import Foundation
import CountryQA

let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
let ask = MainActor.assumeIsolated {
    CountryQACLIComposer.compose(httpClient: httpClient)
}

print("Country Q&A - Ask me about any country!")
print("Examples: 'What is the capital of Belgium?', 'What is the flag of Brazil?'")
print("Type 'retry' to repeat the last question, or 'quit' to exit.\n")

var lastQuestion: String?

Task { @MainActor in
    while true {
        print("> ", terminator: "")
        guard let line = readLine() else { break }
        let input = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if input.isEmpty { continue }
        if input.lowercased() == "quit" { break }
        
        let question: String
        if input.lowercased() == "retry", let last = lastQuestion {
            question = last
        } else {
            question = input
            lastQuestion = input
        }
        
        await ask(question)
        print()
    }
    exit(0)
}

RunLoop.main.run()
