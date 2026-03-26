//
//  WakeLockModifier.swift
//  Sofa
//
//  Created by dukes on 3/26/26.
//

import SwiftUI

struct WakeLockModifier: ViewModifier {

    // MARK: - Private Properties

    private let application: UIApplication = .shared

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .onAppear {
                application.isIdleTimerDisabled = true
            }
            .onDisappear {
                application.isIdleTimerDisabled = false
            }
    }
}
