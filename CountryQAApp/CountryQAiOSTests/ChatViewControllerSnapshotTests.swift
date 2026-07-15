//
//  ChatViewControllerSnapshotTests.swift
//  CountryQAiOSTests
//
//  Created by mike on 2026/7/16.
//

import XCTest
import CountryQA
@testable import CountryQAApp

@MainActor
final class ChatViewControllerSnapshotTests: XCTestCase {

    func test_capitalAnswer_light() {
        let sut = makeSUT()

        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_CAPITAL_light")
    }

    func test_capitalAnswer_dark() {
        let sut = makeSUT()

        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CHAT_CAPITAL_dark")
    }

    func test_flagAnswer_light() {
        let sut = makeSUT()

        sut.simulateUserSends("What is the flag of Cape Verde?")
        sut.display(makeFlagViewModel())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_FLAG_light")
    }

    func test_flagAnswer_afterTheImageLoads_keepsTheMessageAndTheEmojiVisible() async {
        let sut = makeSUT(flagImage: UIImage.solid(color: .systemTeal, size: CGSize(width: 320, height: 213)))

        sut.simulateUserSends("What is the flag of Cape Verde?")
        sut.display(makeFlagViewModel())
        await sut.waitForFlagImage()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_FLAG_WITH_IMAGE_light")
    }

    func test_errorWithRetry_light() {
        let sut = makeSUT()

        sut.display(CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_ERROR_RETRY_light")
    }

    func test_errorWithRetry_dark() {
        let sut = makeSUT()

        sut.display(CountryAnswerViewModel(message: "Something went wrong loading the answer. Please try again.", showsRetry: true))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CHAT_ERROR_RETRY_dark")
    }

    func test_unknownAnswer_light() {
        let sut = makeSUT()

        sut.display(CountryAnswerViewModel(message: "I don't understand that question. Try asking about a country's capital, ISO code, flag, or which countries start with certain letters."))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CHAT_UNKNOWN_light")
    }

    func test_conversation_extraExtraExtraLargeContentSize() {
        let sut = makeSUT()

        sut.simulateUserSends("What is the capital of Belgium?")
        sut.display(CountryAnswerViewModel(message: "The capital of Belgium is Brussels."))

        assert(
            snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .accessibilityExtraExtraExtraLarge)),
            named: "CHAT_CONVERSATION_XXXL"
        )
    }

    // MARK: - Helpers

    private func makeSUT(
        flagImage: UIImage? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ChatViewController {
        let sut = ChatViewController()
        if let data = flagImage?.pngData() {
            sut.imageLoader = { _ in data }
        }
        sut.loadViewIfNeeded()
        return sut
    }

    private func makeFlagViewModel() -> CountryAnswerViewModel {
        CountryAnswerViewModel(
            message: "The flag of Cape Verde",
            flagEmoji: "🇨🇻",
            flagImageURL: URL(string: "https://flagcdn.com/w320/cv.png")
        )
    }
}

@MainActor
private extension ChatViewController {
    /// The flag arrives on a detached Task and reloads its row, so the snapshot has to wait for it.
    func waitForFlagImage(timeout: TimeInterval = 2.0) async {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))

            let showsFlag = view.subviews
                .compactMap { $0 as? UITableView }
                .flatMap(\.visibleCells)
                .compactMap { $0 as? ChatMessageCell }
                .contains(where: \.isShowingFlagImage)

            if showsFlag { return }
        }
    }
}

private extension UIImage {
    static func solid(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
