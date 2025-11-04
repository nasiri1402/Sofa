//
//  HapticFeedbackModifier.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

enum HapticFeedbackType {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

struct HapticFeedbackModifier: ViewModifier {

    // MARK: - Public Properties

    let feedbackType: HapticFeedbackType
    let isEnabled: Bool

    // MARK: - Private Properties

    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    if isEnabled {
                        switch feedbackType {
                        case .selection:
                            selectionFeedbackGenerator.prepare()
                            selectionFeedbackGenerator.selectionChanged()

                        case .notification(let type):
                            notificationFeedbackGenerator.prepare()
                            notificationFeedbackGenerator.notificationOccurred(type)

                        case .impact(let style):
                            let generator = UIImpactFeedbackGenerator(style: style)
                            generator.prepare()
                            generator.impactOccurred()
                        }
                    }
                }
            )
    }
}
