//
//  BriefView.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import Lottie
import SwiftUI

struct BriefView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: BriefViewModel

    // MARK: - Private Properties

    @State private var keyboardHeight: CGFloat = .zero

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                switch viewModel.currentStage {
                case .idea: IdeaPage()
                case .timeframe: TimeframePage()
                case .experience: ExperiencePage()
                case .startPoint: StartPointPage()
                case .result: ResultPage()
                case .budget: BudgetPage()
                case .limits: LimitsPage()
                }
            }
            .overlay(alignment: .top) {
                HStack(spacing: 26.fitW) {
                    BackButton()
                        .opacity(viewModel.isPreviousEnabled ? 1 : 0)

                    ProgressBar(percentage: viewModel.progress)

                    BackButton()
                        .opacity(.zero)
                }
                .padding(.top, 10.fitW)
                .padding(.horizontal, 16.fitW)
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
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
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
            title: viewModel.currentStage.actionTitle(),
            onTap: viewModel.didTapContinueButton
        )
        .transition(.opacity)
    }
}

// MARK: - Pages

extension BriefView {
    private func IdeaPage() -> some View {
        BriefIdeaPage(
            ideaInput: $viewModel.idea,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .idea)
        )
    }

    private func TimeframePage() -> some View {
        BriefTimeframePage(
            selectedTimeframe: $viewModel.timeframe,
            timeframes: Project.Brief.Timeframe.allCases,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .timeframe)
        )
    }

    private func ExperiencePage() -> some View {
        BriefExperiencePage(
            timeframe: viewModel.timeframe ?? .month1,
            selectedExperience: $viewModel.experience,
            experiences: Project.Brief.Experience.allCases,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .experience)
        )
    }

    private func StartPointPage() -> some View {
        BriefStartPointPage(
            startPointInput: $viewModel.startPoint,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .startPoint)
        )
    }

    private func ResultPage() -> some View {
        BriefResultPage(
            goalMoneyInput: $viewModel.goalMoneyText,
            goalSubscribersInput: $viewModel.goalSubscribersText,
            goalOptionInput: $viewModel.goalOptionText,
            selectedGoals: $viewModel.goals,
            goals: Project.Brief.Goal.allCases,
            isGoalMoneyHidden: viewModel.isGoalMoneyHidden,
            isGoalSubscribersHidden: viewModel.isGoalSubscribersHidden,
            isGoalOptionHidden: viewModel.isGoalOptionHidden,
            isPreviousEnabled: $viewModel.isPreviousEnabled,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .result)
        )
    }

    private func BudgetPage() -> some View {
        EmptyView()
//        OnboardingCountryPage(
//            selectedCountry: $viewModel.country,
//            countries: viewModel.countries,
//            searchInput: $viewModel.countrySearchInput,
//            isPreviousEnabled: $viewModel.isPreviousEnabled,
//            isNextEnabled: $viewModel.isNextEnabled,
//            needsReveal: !viewModel.finishedStages.contains(.country)
//        )
    }

    private func LimitsPage() -> some View {
        EmptyView()
        //        OnboardingAboutUsPage(
        //            selectedSource: $viewModel.source,
        //            sources: viewModel.sources,
        //            otherSourceInput: $viewModel.otherSourceText,
        //            isPreviousEnabled: $viewModel.isPreviousEnabled,
        //            isNextEnabled: $viewModel.isNextEnabled,
        //            needsReveal: !viewModel.finishedStages.contains(.aboutUs)
        //        )
    }
}
