//
//  main.swift
//  CountryQACLI
//
//  Created by mike on 2026/7/15.
//

import Foundation
import CountryQA

setvbuf(stdout, nil, _IOLBF, 0)

let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

let console = MainActor.assumeIsolated {
    CountryQACLIComposer.compose(httpClient: httpClient)
}

Task { @MainActor in
    console.greet()

    while true {
        print("> ", terminator: "")

        guard let line = readLine() else { break }
        if await console.handle(line) == .finished { break }

        print()
    }

    exit(0)
}

RunLoop.main.run()
