//
//  ChatViewController.swift
//  CountryQAApp
//
//  Created by mike on 2026/7/16.
//

import UIKit
import CountryQA

public final class ChatViewController: UIViewController, CountryAnswerView {

    enum AccessibilityIdentifier {
        static let input = "chat-input-field"
        static let send = "chat-send-button"
    }

    public var onAsk: ((String) -> Void)?
    public var imageLoader: ((URL) async -> Data?)?

    private enum Bubble {
        case user(text: String)
        case bot(CountryAnswerViewModel)
    }

    private var bubbles: [Bubble] = []
    private var lastQuestion: String?

    /// A loaded flag lives here, not inside the cell: the row has to be reloaded so the table
    /// recomputes its height, otherwise the image's required size squeezes the message and the
    /// emoji out of the bubble.
    private var flagImages: [URL: UIImage] = [:]
    private var flagImageLoads: Set<URL> = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        table.keyboardDismissMode = .interactive
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let inputField: UITextField = {
        let field = UITextField()
        field.placeholder = "Ask about a country..."
        field.borderStyle = .roundedRect
        field.returnKeyType = .send
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.spellCheckingType = .no
        field.accessibilityIdentifier = AccessibilityIdentifier.input
        return field
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Country Q&A"
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        inputField.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseIdentifier)
        setupLayout()
    }

    // MARK: - CountryAnswerView

    public func display(_ viewModel: CountryAnswerViewModel) {
        append(.bot(viewModel))
    }

    // MARK: - Actions

    @objc private func sendTapped() {
        guard let text = inputField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        inputField.text = ""
        lastQuestion = text
        append(.user(text: text))
        onAsk?(text)
    }

    private func retry() {
        guard let question = lastQuestion else { return }
        onAsk?(question)
    }

    private func append(_ bubble: Bubble) {
        bubbles.append(bubble)
        let indexPath = IndexPath(row: bubbles.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Layout

    private func setupLayout() {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.accessibilityIdentifier = AccessibilityIdentifier.send
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        let inputStack = UIStackView(arrangedSubviews: [inputField, sendButton])
        inputStack.axis = .horizontal
        inputStack.spacing = 8
        inputStack.alignment = .center
        inputStack.isLayoutMarginsRelativeArrangement = true
        inputStack.directionalLayoutMargins = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        inputStack.translatesAutoresizingMaskIntoConstraints = false

        let inputContainer = UIView()
        inputContainer.backgroundColor = .secondarySystemBackground
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(inputStack)

        view.addSubview(tableView)
        view.addSubview(inputContainer)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            inputStack.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            inputStack.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            inputStack.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            inputStack.bottomAnchor.constraint(equalTo: inputContainer.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bubbles.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath) as! ChatMessageCell
        switch bubbles[indexPath.row] {
        case let .user(text):
            cell.configure(text: text, isUser: true, showsRetry: false)
        case let .bot(viewModel):
            cell.configure(
                text: viewModel.message,
                isUser: false,
                flagEmoji: viewModel.flagEmoji,
                showsRetry: viewModel.showsRetry,
                onRetry: { [weak self] in self?.retry() }
            )
            if let url = viewModel.flagImageURL {
                cell.setFlagImage(flagImages[url])
                loadFlagImage(from: url, for: indexPath.row)
            }
        }
        return cell
    }

    private func loadFlagImage(from url: URL, for row: Int) {
        guard flagImages[url] == nil, !flagImageLoads.contains(url) else { return }
        flagImageLoads.insert(url)

        Task { [weak self] in
            guard let data = await self?.imageLoader?(url),
                  let image = UIImage(data: data) else {
                self?.flagImageLoads.remove(url)
                return
            }

            guard let self, row < bubbles.count else { return }
            flagImages[url] = image
            flagImageLoads.remove(url)
            tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}
