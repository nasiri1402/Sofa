//
//  OnboardingView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Lottie
import StoreKit
import SwiftUI

struct OnboardingView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: OnboardingViewModel

    // MARK: - Private Properties

    @Environment(\.requestReview) private var requestReview
    @State private var keyboardHeight: CGFloat = .zero

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                switch viewModel.currentStage {
                case .logo: OnboardingLogoPage {
                    viewModel.didFinishStage(.logo)
                }
                case .letsBegin: OnboardingLetsBeginPage {
                    viewModel.didFinishStage(.letsBegin)
                }
                case .name: OnboardingNamePage(nameInput: $viewModel.nameInput) {
                    viewModel.didFinishStage(.name)
                }
                case .gender: GenderPage()
                case .age: AgePage()
                case .country: CountryPage()
                case .aboutUs: AboutUsPage()
                case .privacy: PrivacyPage()
                case .rateUs: RateUsPage()
                case .letsAsk: LetsAskPage()
                }
            }
            .overlay(alignment: .topLeading) {
                if viewModel.isPreviousEnabled {
                    BackButton()
                        .padding(.top, 10.fitW)
                        .padding(.leading, 16.fitW)
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.isNextEnabled {
                    ContinueButton()
                        .padding(.horizontal, 16.fitW)
                        .padding(.bottom, keyboardHeight > .zero ? 16.fitW : 47.fitW)
                }
            }
            .animation(.easeInOut, value: viewModel.currentStage)
            .animation(.easeInOut, value: viewModel.isNextEnabled)
            .animation(.easeInOut, value: viewModel.isPreviousEnabled)
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .overlay {
            ActivityIndicator(isLoading: viewModel.isLoading)
        }
        .onChange(of: viewModel.reviewTrigger) { _, _ in
            requestReview()
        }
        .onChangeKeyboardHeight { newValue in
            guard keyboardHeight != newValue else { return }
            keyboardHeight = newValue
        }
    }

    // MARK: - Views

    private func BackButton() -> some View {
        Button(action: viewModel.didTapBackButton) {
            Image(.backCircle)
                .resizable()
                .frame(width: 46.fitW, height: 46.fitW)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
        .transition(.opacity)
        .opacity(viewModel.isPreviousEnabled ? 1 : 0)
    }

    private func ContinueButton() -> some View {
        PrimaryButton(title: viewModel.currentStage.actionTitle, onTap: viewModel.didTapContinueButton)
            .transition(.opacity)
    }
}

extension OnboardingView {

    // MARK: - NamePage

    private func NamePage() -> some View {
        EmptyView()
    }

    // MARK: - GenderPage

    private func GenderPage() -> some View {
        EmptyView()
    }

    // MARK: - AgePage

    private func AgePage() -> some View {
        EmptyView()
    }

    // MARK: - CountryPage

    private func CountryPage() -> some View {
        EmptyView()
    }

    // MARK: - AboutUsPage

    private func AboutUsPage() -> some View {
        EmptyView()
    }

    // MARK: - PrivacyPage

    private func PrivacyPage() -> some View {
        EmptyView()
    }

    // MARK: - RateUs

    private func RateUsPage() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            LottieView(animation: .named("reviewing"))
                .looping()
                .resizable()
                .frame(width: 150.fitW, height: 150.fitW)

            Text(String(localized: "pleaseRateUs"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16.fitW)
                .multilineTextAlignment(.center)

            Text(String(localized: "pleaseRateUsDescription"))
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer(minLength: .zero)
//            RateButton()
//                .padding(.bottom, 31.fitW)
        }
        .frame(maxWidth: .infinity)
        .transition(.blurReplace.combined(with: .opacity))
        .padding(.top, 154.fitW)
        .padding(16.fitW)
    }

    // MARK: - LetsAskPage

    private func LetsAskPage() -> some View {
        EmptyView()
    }
}
