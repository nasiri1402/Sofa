//
//  OnboardingLetsAsk.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct OnboardingLetsAsk: View {

    // MARK: - Public Properties

    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool

    // MARK: - Private Properties

    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            WordRevealText(
                text: String(localized: "answerQuestionsAboutYourGoalAndGetAnActionPlan"),
                font: .system(size: 34.fitW, weight: .bold),
                onFinished: completeTitleReveal
            )
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: .zero)
        }
        .padding(.top, 256.fitH)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onDisappear {
            transitionTask?.cancel()
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                isNextEnabled = true
            }
        }
    }
}
