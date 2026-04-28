//
//  BriefExperiencePage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefExperiencePage: View {

    // MARK: - Public Properties

    let timeframe: Project.Brief.Timeframe
    @Binding var selectedExperience: Project.Brief.Experience?
    let experiences: [Project.Brief.Experience]
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
                    text: String(localized: "howExperiencedAreYou"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "howExperiencedAreYou"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    ForEach(experiences, id: \.self) { experience in
                        ExperienceButton(experience)
                    }
                }
                .animation(.easeInOut, value: selectedExperience)
                .transition(.move(edge: .bottom).combined(with: .opacity))
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
        .onChange(of: selectedExperience) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != nil
        }
    }

    // MARK: - Views

    private func ExperienceButton(_ experience: Project.Brief.Experience) -> some View {
        Button {
            selectedExperience = experience
        } label: {
            Text(experience.name)
                .multilineMinimumScale()
                .multilineTextAlignment(.center)
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20.fitW)
                .frame(height: 48.fitW)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.gray787880.opacity(0.12))
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                        .opacity(experience == selectedExperience ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
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
