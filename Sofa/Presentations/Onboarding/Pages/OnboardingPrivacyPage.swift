//
//  OnboardingPrivacyPage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct OnboardingPrivacyPage: View {

    // MARK: - Public Properties

    let name: String
    @Binding var isPrivacyRead: Bool
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var topPadding: CGFloat = 256.fitH
    @State private var bottomPadding: CGFloat = 47.fitW
    @State private var isReadEnabled = false
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(format: String(localized: "wellThenShallWeBeginOurJourney"), name),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(format: String(localized: "wellThenShallWeBeginOurJourney"), name))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: .zero)

            if isReadEnabled {
                VStack(alignment: .leading, spacing: 16.fitW) {
                    AIBanner()
                    PrivacyView()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .padding(.bottom, bottomPadding)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                isReadEnabled = false
                topPadding = 256.fitH
                bottomPadding = 47.fitW
            } else {
                isReadEnabled = true
                topPadding = 72.fitW
                bottomPadding = 123.fitW
            }
        }
        .onDisappear {
            transitionTask?.cancel()
        }
    }

    // MARK: - Views

    private func AIBanner() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.starsBlue)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .padding(.trailing, 6.fitW)

            Text(String(localized: "sofaUsesArtificialIntelligence"))
                .multilineMinimumScale()
                .font(.system(size: 13.fitW))
                .foregroundStyle(.grayD1D1D6)
                .frame(maxWidth: .infinity, minHeight: 24.fitW, alignment: .leading)
        }
        .padding(.horizontal, 20.fitW)
        .padding(.vertical, 14.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 12.fitW))
    }

    private func PrivacyView() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Button {
                isPrivacyRead.toggle()
                isNextEnabled.toggle()
            } label: {
                Image(isPrivacyRead ? .checkboxRectSelectedBlue : .checkboxRectUnselected)
                    .resizable()
                    .frame(width: 24.fitW, height: 24.fitW)
                    .padding(.trailing, 6.fitW)
            }
            .buttonStyle(.plain)
            .hapticFeedback()

            Text(.init(String(
                format: String(localized: "iHaveReadAndAgreeToTheTermsAndPrivacy"),
                SofaConstants.AppSupport.terms,
                SofaConstants.AppSupport.privacy
            )))
            .font(.system(size: 12.fitW))
            .foregroundColor(.gray8E8E93)
            .accentColor(.blue007AFF)
            .frame(minHeight: 24.fitW)
            .multilineTextAlignment(.leading)
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                bottomPadding = 123.fitW
                isReadEnabled = true
            } completion: {
                isNextEnabled = true
            }
        }
    }
}
