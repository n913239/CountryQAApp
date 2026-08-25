//
//  SceneDelegate.swift
//  CountryQAApp
//
//  Created by mike on 2026/8/24.
//

import UIKit
import CountryQA

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var interpreter: QuestionInterpreter = SceneDelegate.makeDefaultInterpreter()

    override init() {
        super.init()
    }

    convenience init(httpClient: HTTPClient, interpreter: QuestionInterpreter) {
        self.init()
        self.httpClient = httpClient
        self.interpreter = interpreter
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = UINavigationController(
            rootViewController: CountryQAUIComposer.compose(httpClient: httpClient, interpreter: interpreter)
        )
        window?.makeKeyAndVisible()
    }

    private static func makeDefaultInterpreter() -> QuestionInterpreter {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
        return CountryQAFactory.makeGeminiInterpreter(httpClient: client, apiKey: apiKey)
    }
}
