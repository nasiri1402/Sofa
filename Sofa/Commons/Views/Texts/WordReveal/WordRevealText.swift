//
//  WordRevealText.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct WordRevealText: View {

    // MARK: - Public Properties

    let text: String
    let font: Font
    var revealedColor: Color = .white
    var hiddenColor: Color = .white.opacity(.zero)
    var wordRevealDelay: Double = 0.3
    var pauseAfterReveal: Double = 2
    var animationDuration: Double = 0.25
    var onFinished: (() -> Void)?

    // MARK: - Private Properties

    @State private var segments: [WordSegment] = []
    @State private var revealedWordCount = 0
    @State private var animationTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        RenderedText()
            .font(font)
            .onAppear { restartAnimation() }
            .onChange(of: text) { _, _ in
                restartAnimation()
            }
            .onDisappear { cancelAnimation() }
    }

    // MARK: - Views

    private func RenderedText() -> Text {
        segments.reduce(Text(verbatim: "")) { partial, segment in
            let color: Color

            if let order = segment.wordOrder {
                color = order < revealedWordCount ? revealedColor : hiddenColor
            } else {
                color = hiddenColor
            }

            return partial + Text(segment.text).foregroundStyle(color)
        }
    }
}

// MARK: - Private Methods

private extension WordRevealText {
    @MainActor
    func restartAnimation() {
        cancelAnimation()
        segments = segments(from: text)
        revealedWordCount = .zero
        animationTask = Task {
            do {
                let totalWords = segments.compactMap(\.wordOrder).count

                guard totalWords > .zero else {
                    if pauseAfterReveal > .zero {
                        try await Task.sleep(for: .seconds(pauseAfterReveal))
                    }
                    await MainActor.run {
                        onFinished?()
                    }
                    return
                }
                for index in 1...totalWords {
                    if wordRevealDelay > .zero {
                        try await Task.sleep(for: .seconds(wordRevealDelay))
                    }
                    await MainActor.run {
                        withAnimation(.easeOut(duration: animationDuration)) {
                            revealedWordCount = index
                        }
                    }
                }
                if pauseAfterReveal > .zero {
                    try await Task.sleep(for: .seconds(pauseAfterReveal))
                }

                await MainActor.run {
                    onFinished?()
                }
            } catch is CancellationError {
                // Если задача отменена, ничего не делаем
            } catch {
                await MainActor.run {
                    onFinished?()
                }
            }
        }
    }

    func cancelAnimation() {
        animationTask?.cancel()
        animationTask = nil
    }

    func segments(from text: String) -> [WordSegment] {
        var segments: [WordSegment] = []
        var buffer = ""
        var isCurrentWord: Bool?
        var wordOrder = 0
        let onFlush = {
            guard !buffer.isEmpty else { return }

            if isCurrentWord == true {
                segments.append(WordSegment(text: buffer, wordOrder: wordOrder))
                wordOrder += 1
            } else {
                segments.append(WordSegment(text: buffer, wordOrder: nil))
            }
            buffer.removeAll(keepingCapacity: true)
        }
        for character in text {
            let isWordCharacter = !character.isWhitespace

            if let current = isCurrentWord, current != isWordCharacter {
                onFlush()
            }
            isCurrentWord = isWordCharacter
            buffer.append(character)
        }
        onFlush()

        return segments
    }

}

// MARK: - WordSegment

private extension WordRevealText {
    struct WordSegment {
        let text: String
        let wordOrder: Int?
    }
}
