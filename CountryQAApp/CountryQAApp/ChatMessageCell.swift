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
        static let flagImage = "chat-flag-image"
    }
    
    var flagImageURL: URL?
    
    private let bubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityIdentifier = AccessibilityIdentifier.bubbleLabel
        return label
    }()
    
    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.accessibilityIdentifier = AccessibilityIdentifier.flagImage
        return imageView
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.isHidden = true
        button.accessibilityIdentifier = AccessibilityIdentifier.retryButton
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bubbleLabel, flagImageView, retryButton])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        stack.alignment = isUser ? .trailing : .leading
        retryButton.isHidden = !showsRetry
        flagImageView.isHidden = true
        flagImageView.image = nil
        flagImageURL = nil
        self.onRetry = onRetry
        selectionStyle = .none
    }
    
    func setFlagImage(_ image: UIImage?) {
        flagImageView.image = image
        flagImageView.isHidden = image == nil
    }
    
    // MARK: - Actions
    
    @objc private func retryTapped() {
        onRetry?()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            flagImageView.widthAnchor.constraint(equalToConstant: 140),
            flagImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
