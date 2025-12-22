//
//  OnboardingGenderPage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct OnboardingGenderPage: View {

    // MARK: - Public Properties

    let name: String
    @Binding var selectedGender: Profile.Gender?
    let genders: [Profile.Gender]
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var phase: Phase = .one
    @State private var isSelectionEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: phase.text + (phase == .one ? ", " + name : ""),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: advanceToNextPhase
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whatShouldICallYou"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    ForEach(genders, id: \.self) { gender in
                        GenderButton(gender)
                    }
                }
                .animation(.easeInOut, value: selectedGender)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                phase = .one
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
    }

    // MARK: - Views

    private func GenderButton(_ gender: Profile.Gender) -> some View {
        Button {
            selectedGender = gender
        } label: {
            HStack(spacing: .zero) {
                Text(name)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)

                Text(" (" + gender.name + ")")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .lineLimit(1)
            .padding(.horizontal, 20.fitW)
            .frame(height: 48.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray787880.opacity(0.12))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(gender == selectedGender ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    // MARK: - Private Methods

    @MainActor
    func advanceToNextPhase() {
        guard let next = nextPhase(after: phase) else {
            completeTitleReveal()
            return
        }
        phase = next
    }

    func nextPhase(after phase: Phase) -> Phase? {
        guard let index = Phase.allCases.firstIndex(of: phase) else { return nil }
        return Phase.allCases[safe: index + 1]
    }

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        isNextEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isSelectionEnabled = true
            }
        }
    }
}

// MARK: - Types

extension OnboardingGenderPage {
    enum Phase: Int, CaseIterable {
        case one, two

        var text: String {
            switch self {
            case .one: String(localized: "niceToMeetYou")
            case .two: String(localized: "whatShouldICallYou")
            }
        }
    }
}
