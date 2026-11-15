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

    @Environment(\.isTabBarHidden) private var isTabBarHidden
    @State private var keyboardHeight: CGFloat = .zero

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                switch viewModel.currentStage {
                case .category: CategoryPage()
                case .focus: FocusPage()
                case .target: TargetPage()
                case .currentState: CurrentStatePage()
                case .preferences: PreferencesPage()
                case .timeframe: TimeframePage()
                }
            }
            .overlay(alignment: .top) {
                HStack(spacing: 26.fitW) {
                    BackButton()
                        .opacity(viewModel.isPreviousEnabled ? 1 : 0)

                    ProgressBar(percentage: viewModel.progress, isGreenCompleted: false)
                        .transition(.opacity)

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
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
            viewModel.didViewAppear()
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
    private func CategoryPage() -> some View {
        BriefCategoryPage(
            selectedCategory: viewModel.category,
            categories: Project.Brief.Category.allCases,
            isNextEnabled: $viewModel.isNextEnabled,
            needsReveal: viewModel.needsReveal(for: .category),
            onSelect: viewModel.selectCategory
        )
    }

    @ViewBuilder
    private func FocusPage() -> some View {
        if let category = viewModel.category {
            BriefFocusPage(
                category: category,
                selectedFocus: viewModel.focus,
                isPreviousEnabled: $viewModel.isPreviousEnabled,
                isNextEnabled: $viewModel.isNextEnabled,
                needsReveal: viewModel.needsReveal(for: .focus),
                onSelect: viewModel.selectFocus
            )
        }
    }

    @ViewBuilder
    private func TargetPage() -> some View {
        if let category = viewModel.category {
            BriefTextInputPage(
                text: $viewModel.target,
                title: category.targetQuestion,
                tip: category.targetTip,
                placeholder: placeholder,
                typewriterOptions: category.targetExamples,
                isPreviousEnabled: $viewModel.isPreviousEnabled,
                isNextEnabled: $viewModel.isNextEnabled,
                needsReveal: viewModel.needsReveal(for: .target)
            )
        }
    }

    @ViewBuilder
    private func CurrentStatePage() -> some View {
        if let category = viewModel.category {
            BriefTextInputPage(
                text: $viewModel.currentState,
                title: category.currentStateQuestion,
                tip: category.currentStateTip,
                placeholder: placeholder,
                typewriterOptions: category.currentStateExamples,
                isPreviousEnabled: $viewModel.isPreviousEnabled,
                isNextEnabled: $viewModel.isNextEnabled,
                needsReveal: viewModel.needsReveal(for: .currentState)
            )
        }
    }

    @ViewBuilder
    private func PreferencesPage() -> some View {
        if let category = viewModel.category {
            BriefPreferencesPage(
                preferences: $viewModel.preferences,
                tip: category.preferencesTip,
                placeholder: placeholder,
                typewriterOptions: category.preferenceExamples,
                noPreferencesText: BriefLocalization.text(
                    en: "I have no preferences", ru: "У меня нет пожеланий"),
                isPreviousEnabled: $viewModel.isPreviousEnabled,
                isNextEnabled: $viewModel.isNextEnabled,
                needsReveal: viewModel.needsReveal(for: .preferences)
            )
        }
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

    private var placeholder: String {
        String(localized: "forExample") + ", "
    }
}
