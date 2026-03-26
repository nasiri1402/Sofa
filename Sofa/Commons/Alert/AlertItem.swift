//
//  AlertItem.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let primaryButton: Alert.Button
    var secondaryButton: Alert.Button?

    func alert() -> Alert {
        if let secondaryButton {
            Alert(
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        } else {
            Alert(title: title, message: message, dismissButton: primaryButton)
        }
    }
}

extension AlertItem {
    static func error(message: String, action: @escaping () -> Void = {}) -> AlertItem {
        AlertItem(
            title: Text(String(localized: "error")),
            message: Text(message),
            primaryButton: .default(Text(String(localized: "ok")), action: action),
            secondaryButton: nil
        )
    }

    static func settings(title: String, message: String) -> AlertItem {
        AlertItem(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(Text(String(localized: "settings"))) {
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url)
                else { return }
                UIApplication.shared.open(url)
            },
            secondaryButton: .cancel(Text(String(localized: "cancel")))
        )
    }
}
