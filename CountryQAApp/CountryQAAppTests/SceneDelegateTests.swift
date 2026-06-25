//
//  SceneDelegateTests.swift
//  CountryQAAppTests
//
//  Created by mike on 2026/6/26.
//

import XCTest
import CountryQA
@testable import CountryQAApp

@MainActor
final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() throws {
        let sut = makeSUT()
        let window = try UIWindowSpy.make()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    func test_configureWindow_configuresRootChatViewController() throws {
        let sut = makeSUT()
        sut.window = try UIWindowSpy.make()
        
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        XCTAssertTrue(nav?.topViewController is ChatViewController, "Expected ChatViewController as navigation root, got \(String(describing: nav?.topViewController)) instead")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SceneDelegate {
        let sut = SceneDelegate(httpClient: HTTPClientStub())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private final class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount = 0
        
        static func make() throws -> UIWindowSpy {
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            return UIWindowSpy(windowScene: dummyScene)
        }
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }
    
    private final class HTTPClientStub: HTTPClient {
        func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
            try await Task.sleep(for: .seconds(60 * 60))
            throw NSError(domain: "never", code: 0)
        }
    }
}
