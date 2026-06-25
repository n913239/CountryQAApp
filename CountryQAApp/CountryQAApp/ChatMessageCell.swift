//
//  ChatMessageCell.swift
//  CountryQAApp
//
//  Created by mike on 2026/6/25.
//

import UIKit

final class ChatMessageCell: UITableViewCell {
    static let reuseIdentifier = "ChatMessageCell"
    
    enum AccessibilityIdentifier {
        static let bubbleLabel = "chat-bubble-label"
        static let retryButton = "chat-retry-button"
    }
    
    private let bubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = AccessibilityIdentifier.bubbleLabel
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = AccessibilityIdentifier.retryButton
        return button
    }()
    
    private var onRetry: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    func configure(text: String, isUser: Bool, showsRetry: Bool, onRetry: (() -> Void)? = nil) {
        bubbleLabel.text = text
        bubbleLabel.textColor = isUser ? .label : .secondaryLabel
        bubbleLabel.textAlignment = isUser ? .right : .left
        retryButton.isHidden = !showsRetry
        self.onRetry = onRetry
        selectionStyle = .none
    }
    
    // MARK: - Actions
    
    @objc private func retryTapped() {
        onRetry?()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        contentView.addSubview(bubbleLabel)
        contentView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            bubbleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: bubbleLabel.bottomAnchor, constant: 4),
            retryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            retryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
