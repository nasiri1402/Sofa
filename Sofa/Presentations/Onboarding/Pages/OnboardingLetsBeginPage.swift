//
//  OnboardingLetsBeginPage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingLetsBeginPage: View {

    // MARK: - Public Properties

    @Binding var isNextEnabled: Bool

    // MARK: - Private Properties

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            WordRevealText(
                text: [
                    String(localized: "hello") + " 👋",
                    String(localized: "myNameIsSofa")
                ].joined(separator: "\n"),
                font: .system(size: 34.fitW, weight: .bold),
                onFinished: completeTitleReveal
            )
            .padding(.top, 256.fitH)

            Spacer()
        }
        .padding(.horizontal, 16.fitW)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Private Methods

    @MainActor
    func completeTitleReveal() {
        isNextEnabled = true
    }
}
