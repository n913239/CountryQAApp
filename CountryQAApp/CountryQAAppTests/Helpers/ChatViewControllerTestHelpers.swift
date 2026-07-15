//
//  ChatViewControllerTestHelpers.swift
//  CountryQAAppTests
//
//  Created by mike on 2026/7/16.
//

import UIKit
@testable import CountryQAApp

@MainActor
extension ChatViewController {
    func simulateUserSends(_ text: String) {
        loadViewIfNeeded()
        let field = view.findView(withAccessibilityIdentifier: AccessibilityIdentifier.input) as? UITextField
        field?.text = text
        let sendButton = view.findView(withAccessibilityIdentifier: AccessibilityIdentifier.send) as? UIButton
        sendButton?.sendActions(for: .touchUpInside)
    }

    func simulateRetry() {
        let cells = renderedCells()
        for cell in cells {
            guard let button = cell.findView(withAccessibilityIdentifier: ChatMessageCell.AccessibilityIdentifier.retryButton) as? UIButton, !button.isHidden else { continue }
            button.sendActions(for: .touchUpInside)
            return
        }
    }

    var bubbleTexts: [String] {
        renderedCells().compactMap {
            ($0.findView(withAccessibilityIdentifier: ChatMessageCell.AccessibilityIdentifier.bubbleLabel) as? UILabel)?.text
        }
    }

    var retryButton: UIButton? {
        renderedCells().lazy.compactMap {
            $0.findView(withAccessibilityIdentifier: ChatMessageCell.AccessibilityIdentifier.retryButton) as? UIButton
        }.first { !$0.isHidden }
    }

    private func renderedCells() -> [UITableViewCell] {
        guard let table = chatTableView, let dataSource = table.dataSource else { return [] }
        table.reloadData()
        let rows = dataSource.tableView(table, numberOfRowsInSection: 0)
        return (0..<rows).map { dataSource.tableView(table, cellForRowAt: IndexPath(row: $0, section: 0)) }
    }

    private var chatTableView: UITableView? {
        view.firstSubview(ofType: UITableView.self)
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

    func firstSubview<T: UIView>(ofType type: T.Type) -> T? {
        if let typed = self as? T { return typed }
        for subview in subviews {
            if let match = subview.firstSubview(ofType: type) {
                return match
            }
        }
        return nil
    }
}
