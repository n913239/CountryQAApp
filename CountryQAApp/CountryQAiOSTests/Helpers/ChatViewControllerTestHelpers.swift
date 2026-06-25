//
//  ChatViewControllerTestHelpers.swift
//  CountryQATests
//
//  Created by mike on 2026/6/26.
//

import UIKit
@testable import CountryQAApp

extension ChatViewController {
    func simulateUserSends(_ text: String) {
        loadViewIfNeeded()
        let field = view.findView(withAccessibilityIdentifier: AccessibilityIdentifier.input) as? UITextField
        field?.text = text
        let sendButton = view.findView(withAccessibilityIdentifier: AccessibilityIdentifier.send) as? UIButton
        sendButton?.sendActions(for: .touchUpInside)
    }
}

extension UIView {
    func findView(withAccessibilityIdentifier identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier { return self }
        for subview in subviews {
            if let match = subview.findView(withAccessibilityIdentifier: identifier) {
                return match
            }
        }
        return nil
    }
}
