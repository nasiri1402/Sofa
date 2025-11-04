//
//  KeyboardHeightModifier.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct KeyboardHeightModifier: ViewModifier {

    // MARK: - Public Properties

    let onChange: (CGFloat) -> Void

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            ) {
                handleKeyboardNotification($0, isShowing: true)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            ) {
                handleKeyboardNotification($0, isShowing: false)
            }
    }

    // MARK: - Private Methods

    private func handleKeyboardNotification(_ notification: Notification, isShowing: Bool) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        onChange(isShowing ? frame.height : .zero)
    }
}
