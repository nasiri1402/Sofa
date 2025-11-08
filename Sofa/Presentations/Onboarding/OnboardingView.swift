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
                case .aboutUsOther: AboutUsOtherPage()
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
        .environment(\.openURL, OpenURLAction { url in
            viewModel.didTapPrivacyLink(url: url)
            return .discarded
        })
        .sheet(isPresented: $viewModel.isSafariPresented) {
            if let url = viewModel.safariURL {
                SafariView(url: url)
            }
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .onChange(of: viewModel.reviewTrigger) { _, _ in
            requestReview()
        }
        .onChangeKeyboardHeight { newValue in
            guard keyboardHeight != newValue else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
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
        PrimaryButton(
            title: viewModel.currentStage.actionTitle(
                isForceContinue: viewModel.currentStage == .rateUs && viewModel.isReviewRequested
            ),
            onTap: viewModel.didTapContinueButton
        )
        .transition(.opacity)
    }
}

// MARK: - Pages

extension OnboardingView {
    private func LogoPage() -> some View {
        OnboardingLogoPage(onFinish: viewModel.didTapContinueButton)
    }

    private func LetsBeginPage() -> some View {
        OnboardingLetsBeginPage(isNextEnabled: $viewModel.isNextEnabled)
    }

    private func NamePage() -> some View {
        OnboardingNamePage(
            nameInput: $viewModel.name,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.name)
        )
    }

    private func GenderPage() -> some View {
        OnboardingGenderPage(
            name: viewModel.name,
            selectedGender: $viewModel.gender,
            genders: Profile.Gender.allCases,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.gender)
        )
    }

    private func AgePage() -> some View {
        OnboardingAgePage(
            selectedAge: $viewModel.age,
            ages: viewModel.ages,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.age)
        )
    }

    private func CountryPage() -> some View {
        OnboardingCountryPage(
            selectedCountry: $viewModel.country,
            countries: viewModel.countries,
            searchInput: $viewModel.countrySearchInput,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.country)
        )
    }

    private func AboutUsPage() -> some View {
        OnboardingAboutUsPage(
            selectedSource: $viewModel.source,
            sources: OnboardingModel.Source.allCases,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.aboutUs)
        )
    }

    private func AboutUsOtherPage() -> some View {
        OnboardingAboutUsOtherPage(
            otherSourceInput: $viewModel.otherSourceText,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled
        )
    }

    private func PrivacyPage() -> some View {
        OnboardingPrivacyPage(
            name: viewModel.name,
            isPrivacyRead: $viewModel.isPrivacyRead,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: !viewModel.revealedStages.contains(.privacy)
        )
    }

    private func RateUsPage() -> some View {
        OnboardingRateUsPage(
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled
        )
    }

    private func LetsAskPage() -> some View {
        OnboardingLetsAsk(
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled
        )
    }
}
