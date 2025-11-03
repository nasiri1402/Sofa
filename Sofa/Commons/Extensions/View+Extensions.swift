//
//  View+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

// MARK: - Modifiers

extension View {
    /// Добавляет тактильную отдачу к представлению в зависимости от указанного типа.
    /// - Parameters:
    ///  - feedbackType: Тип тактильной отдачи. По умолчанию `impact.light`.
    ///  - isEnabled: Активна ли тактильная отдача. По умолчанию `true`.
    func hapticFeedback(
        _ feedbackType: HapticFeedbackType = .impact(.light),
        isEnabled: Bool = true
    ) -> some View {
        modifier(
            HapticFeedbackModifier(
                feedbackType: feedbackType,
                isEnabled: isEnabled
            )
        )
    }
}
