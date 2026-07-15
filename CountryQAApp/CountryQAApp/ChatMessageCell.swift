//
//  ChatMessageCell.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/16.
//

import UIKit

final class ChatMessageCell: UITableViewCell {
    static let reuseIdentifier = "ChatMessageCell"

    enum AccessibilityIdentifier {
        static let bubbleLabel = "chat-bubble-label"
        static let retryButton = "chat-retry-button"
        static let flagImage = "chat-flag-image"
        static let flagEmoji = "chat-flag-emoji"
    }

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityIdentifier = AccessibilityIdentifier.bubbleLabel
        return label
    }()

    private let flagEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64)
        label.isHidden = true
        label.accessibilityIdentifier = AccessibilityIdentifier.flagEmoji
        return label
    }()

    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
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
        let stack = UIStackView(arrangedSubviews: [bubbleLabel, flagEmojiLabel, flagImageView, retryButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var onRetry: (() -> Void)?
    private var leadingBubbleConstraint: NSLayoutConstraint?
    private var trailingBubbleConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    func configure(
        text: String,
        isUser: Bool,
        flagEmoji: String? = nil,
        showsRetry: Bool = false,
        onRetry: (() -> Void)? = nil
    ) {
        bubbleLabel.text = text
        bubbleLabel.textColor = isUser ? .white : .label
        bubbleView.backgroundColor = isUser ? .systemBlue : .secondarySystemBackground

        leadingBubbleConstraint?.isActive = !isUser
        trailingBubbleConstraint?.isActive = isUser

        flagEmojiLabel.text = flagEmoji
        flagEmojiLabel.isHidden = flagEmoji == nil

        retryButton.isHidden = !showsRetry
        setFlagImage(nil)
        self.onRetry = onRetry
        selectionStyle = .none
    }

    var isShowingFlagImage: Bool {
        !flagImageView.isHidden && flagImageView.image != nil
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
        backgroundColor = .clear
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(stack)

        let flagWidth = flagImageView.widthAnchor.constraint(equalToConstant: 140)
        let flagHeight = flagImageView.heightAnchor.constraint(equalToConstant: 90)
        flagWidth.priority = .defaultHigh
        flagHeight.priority = .defaultHigh

        bubbleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        flagEmojiLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        leadingBubbleConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingBubbleConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.78),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),

            flagWidth,
            flagHeight
        ])
    }
}
