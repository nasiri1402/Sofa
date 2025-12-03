//
//  OnboardingAgePage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct OnboardingAgePage: View {

    // MARK: - Public Properties

    @Binding var selectedAge: Int
    let ages: [Int]
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var isSelectionEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "howOldAreYou"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "howOldAreYou"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                Spacer(minLength: .zero)

                AgePicker()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 129.fitW)
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                isSelectionEnabled = false
                topPadding = 256.fitH
            } else {
                isSelectionEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            transitionTask?.cancel()
        }
        .onChange(of: selectedAge) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != .zero
        }
    }

    // MARK: - Views

    private func AgePicker() -> some View {
        Picker(String(""), selection: $selectedAge) {
            ForEach(ages, id: \.self) { age in
                Text(
                    age == .zero
                    ? String(localized: "notSelected")
                    : age.description + (age == ages.last ? "+" : "")
                )
                .font(.system(size: 24.fitW, weight: .semibold))
                .foregroundStyle(.white)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isSelectionEnabled = true
            }
        }
    }
}
