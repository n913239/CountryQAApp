//
//  CountryQAAcceptanceTests.swift
//  CountryQAAppTests
//
//  Created by mike on 2026/6/26.
//

import XCTest
import CountryQA
@testable import CountryQAApp

@MainActor
final class CountryQAAcceptanceTests: XCTestCase {
    
    func test_userAsksCapital_displaysAnswer() async throws {
        let chat = try launch(httpClient: HTTPClientStub(result: .success(belgiumResponse())))
        
        chat.simulateUserSends("What is the capital of Belgium?")
        await waitForUI()
        
        XCTAssertTrue(chat.bubbleTexts.contains("The capital of Belgium is Brussels."), "Expected the answer bubble, got \(chat.bubbleTexts)")
    }
    
    func test_userAsks_whenLoadFails_showsRetry_andRecoversOnRetry() async throws {
        let stub = HTTPClientStub(result: .failure(anyError()))
        let chat = try launch(httpClient: stub)
        
        chat.simulateUserSends("What is the capital of Belgium?")
        await waitForUI()
        
        XCTAssertNotNil(chat.retryButton, "Expected a Retry button after a failed load")
        
        stub.result = .success(belgiumResponse())
        chat.simulateRetry()
        await waitForUI()
        
        XCTAssertTrue(chat.bubbleTexts.contains("The capital of Belgium is Brussels."), "Expected the answer bubble after retry, got \(chat.bubbleTexts)")
    }
    
    // MARK: - Helpers
    
    private var heldSceneDelegate: SceneDelegate?
    
    private func launch(httpClient: HTTPClientStub, file: StaticString = #filePath, line: UInt = #line) throws -> ChatViewController {
        let sceneDelegate = SceneDelegate(httpClient: httpClient)
        heldSceneDelegate = sceneDelegate
        let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
        sceneDelegate.window = UIWindow(windowScene: dummyScene)
        sceneDelegate.window?.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        sceneDelegate.configureWindow()
        
        let nav = try XCTUnwrap(sceneDelegate.window?.rootViewController as? UINavigationController, file: file, line: line)
        let chat = try XCTUnwrap(nav.topViewController as? ChatViewController, file: file, line: line)
        chat.loadViewIfNeeded()
        return chat
    }
    
    override func tearDown() {
        heldSceneDelegate = nil
        super.tearDown()
    }
    
    private func waitForUI() async {
        for _ in 0..<30 {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(50))
        }
    }
    
    private func anyError() -> NSError {
        NSError(domain: "offline", code: 0)
    }
    
    private func belgiumResponse() -> (Data, HTTPURLResponse) {
        let json: [[String: Any]] = [[
            "name": ["common": "Belgium"],
            "capital": ["Brussels"],
            "cca2": "BE",
            "flag": "🇧🇪",
            "flags": ["png": "https://flagcdn.com/w320/be.png"]
        ]]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: URL(string: "https://restcountries.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

private final class HTTPClientStub: HTTPClient, @unchecked Sendable {
    var result: Result<(Data, HTTPURLResponse), Error>
    
    init(result: Result<(Data, HTTPURLResponse), Error>) {
        self.result = result
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        try result.get()
    }
}
