 //
//  SceneDelegate.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/14.
//

import UIKit
import CountryQA

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

    override init() {
        super.init()
    }

    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = UINavigationController(
            rootViewController: CountryQAUIComposer.compose(httpClient: httpClient)
        )
        window?.makeKeyAndVisible()
    }
}
