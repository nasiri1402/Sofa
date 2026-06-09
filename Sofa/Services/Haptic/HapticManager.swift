//
//  Haptic.swift
//  Sofa
//
//  Created by dukes on 6/9/26.
//

import SwiftUI

// MARK: - Interfaces

@MainActor
protocol Haptic {
    func trigger(_ feedback: HapticFeedback)
}

// MARK: - Types

enum HapticFeedback {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

// MARK: - Implementations

@MainActor
final class DefaultHaptic: Haptic {

    // MARK: - Private Properties

    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

    // MARK: - Public Methods

    func trigger(_ feedback: HapticFeedback) {
        switch feedback {
        case let .impact(style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()

        case let .notification(type):
            notificationFeedbackGenerator.prepare()
            notificationFeedbackGenerator.notificationOccurred(type)

        case .selection:
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
}
