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
                case .logo: LogoPage()
                case .letsBegin: LetsBeginPage()
                case .name: NamePage()
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
            ActivityIndicator(isLoading: viewModel.isReviewing)
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

// MARK: - Pages

extension OnboardingView {

    // MARK: - LogoPage

    private func LogoPage() -> some View {
        OnboardingLogoPage(onFinish: viewModel.didFinishStage)
    }

    // MARK: - LetsBeginPage

    private func LetsBeginPage() -> some View {
        OnboardingLetsBeginPage(isNextEnabled: $viewModel.isNextEnabled)
    }

    // MARK: - NamePage

    private func NamePage() -> some View {
        OnboardingNamePage(
            nameInput: $viewModel.name,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.finishedStages.contains(.name)
        )
    }

    // MARK: - GenderPage

    private func GenderPage() -> some View {
        OnboardingGenderPage(
            name: viewModel.name,
            selectedGender: $viewModel.gender,
            genders: viewModel.allGenders,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.finishedStages.contains(.gender)
        )
    }

    // MARK: - AgePage

    private func AgePage() -> some View {
        OnboardingAgePage(
            selectedAge: $viewModel.age,
            ages: viewModel.ages,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.finishedStages.contains(.age)
        )
    }

    // MARK: - CountryPage

    private func CountryPage() -> some View {
        OnboardingCountryPage(
            selectedCountry: $viewModel.country,
            countries: viewModel.countries,
            searchInput: $viewModel.countrySearchInput,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.finishedStages.contains(.country)
        )
    }

    // MARK: - AboutUsPage

    private func AboutUsPage() -> some View {
        OnboardingAboutUsPage(
            selectedSource: $viewModel.source,
            sources: viewModel.sources,
            otherSourceInput: $viewModel.otherSourceText,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.finishedStages.contains(.aboutUs)
        )
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
