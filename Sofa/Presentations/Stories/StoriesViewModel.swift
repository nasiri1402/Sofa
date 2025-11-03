//
//  StoriesViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class StoriesViewModel {

    // MARK: - Public Properties

    let story: StoriesModel.Story
    private(set) var pages: [StoriesModel.Page] = []
    var currentPageIndex: Int? {
        didSet {
            guard oldValue != currentPageIndex else { return }
            updatePageCounter()
        }
    }
    private(set) var pageCounter = ""
    private(set) var dismissTrigger = UUID()

    // MARK: - Inits

    init(story: StoriesModel.Story) {
        self.story = story

        initialize()
    }
}

// MARK: - Public Methods

extension StoriesViewModel {

    // MARK: - Input

    func didTapNextButton() {
        guard let currentPageIndex else { return }
        // Проверяем, последняя ли страница
        if currentPageIndex == pages.count - 1 {
            dismissTrigger = UUID()
            return
        }
        withAnimation {
            self.currentPageIndex = currentPageIndex + 1
        }
    }
}

// MARK: - Private Methods

extension StoriesViewModel {
    private func initialize() {
        pages = switch story {
        case .green: [
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyGreenPage1Title"), emoji: "💡"),
                tips: [StoriesModel.Page.PageText(text: String(localized: "storyGreenPage1Tip"), emoji: "💬")]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyGreenPage2Title"), emoji: nil),
                tips: [
                    StoriesModel.Page.PageText(text: String(localized: "storyGreenPage2Tip1"), emoji: "❌"),
                    StoriesModel.Page.PageText(text: String(localized: "storyGreenPage2Tip2"), emoji: "✅")
                ]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyGreenPage3Title"), emoji: "✨"),
                tips: [StoriesModel.Page.PageText(text: String(localized: "storyGreenPage3Tip"), emoji: nil)]
            )
        ]
        case .orange: [
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyOrangePage1Title"), emoji: "❓"),
                tips: [StoriesModel.Page.PageText(text: String(localized: "storyOrangePage1Tip"), emoji: "🤔")]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyOrangePage2Title"), emoji: nil),
                tips: [StoriesModel.Page.PageText(text: String(localized: "storyOrangePage2Tip"), emoji: "🔁")]
            )
        ]
        case .red: [
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyRedPage1Title"), emoji: "✖️"),
                tips: [
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage1Tip1"), emoji: "❌"),
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage1Tip2"), emoji: nil),
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage1Tip3"), emoji: "✅")
                ]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyRedPage2Title"), emoji: "✖️"),
                tips: [
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage2Tip1"), emoji: nil),
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage2Tip2"), emoji: "✅")
                ]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyRedPage3Title"), emoji: "✖️"),
                tips: [
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage3Tip1"), emoji: nil),
                    StoriesModel.Page.PageText(text: String(localized: "storyRedPage3Tip2"), emoji: "✅")
                ]
            ),
            StoriesModel.Page(
                title: StoriesModel.Page.PageText(text: String(localized: "storyRedPage4Title"), emoji: "💡"),
                tips: [StoriesModel.Page.PageText(text: String(localized: "storyRedPage4Tip"), emoji: "🚀")]
            )
        ]
        }
        currentPageIndex = .zero
    }

    private func updatePageCounter() {
        guard let currentPageIndex else { return }
        pageCounter = (currentPageIndex + 1).description + "/" + pages.count.description
    }
}
