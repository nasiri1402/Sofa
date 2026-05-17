//
//  StepTreeView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Lottie
import SwiftUI

struct StepTreeView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: StepTreeViewModel

    // MARK: - Private Properties

    @Environment(\.isTabBarHidden) private var isTabBarHidden

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            List {
                PlanInfoView()
                    .padding(.bottom, 24.fitW)
                    .plainListRowStyle()

                if viewModel.isWellDone {
                    WellDoneView()
                        .plainListRowStyle()
                } else {
                    WeeksScrollView()
                        .padding(.bottom, 8.fitW)
                        .plainListRowStyle()

                    ForEach(viewModel.selectedWeek?.steps ?? [], id: \.id) { step in
                        StepButton(step)
                            .padding(.vertical, 8.fitW)
                            .plainListRowStyle()
                    }
                    .onMove(perform: viewModel.didMoveStep)

                    AddStepButton()
                        .padding(.top, 8.fitW)
                        .plainListRowStyle()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.vertical, 24.fitW, for: .scrollContent)
            .padding(.horizontal, 16.fitW)
            .overlay(alignment: .bottom) {
                VStack {
                    if viewModel.isWellDone {
                        ViewPlanButton()
                    } else {
                        AskAssistantButton()
                    }
                }
                .padding(16.fitW)
            }
            .animation(.easeInOut, value: viewModel.isWellDone)
        }
        .navigationTitle(String(localized: "stepTree"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarLeadingButton(icon: .back) {
            viewModel.didTapNavigationBarLeadingButton()
        }
        .navigationBarTrailingButton(icon: viewModel.plan.isFavorite ? .like : .unlike) {
            viewModel.didTapNavigationBarTrailingButton()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .textFieldAlert(item: $viewModel.textFieldAlertItem)
        .fullScreenCover(isPresented: $viewModel.isPaywallPresented) {
            PaywallCover()
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
        }
    }

    // MARK: - Views

    private func PlanInfoView() -> some View {
        VStack(alignment: .leading, spacing: 12.fitW) {
            VStack(alignment: .leading, spacing: 6.fitW) {
                Text(viewModel.plan.emoji + " " + viewModel.plan.title)
                    .font(.system(size: 22.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                DifficultyStepsView(
                    difficulty: viewModel.plan.difficulty,
                    steps: viewModel.plan.allSteps.count
                )
            }
            Divider()
            DescriptionText(
                icon: .firstResults,
                title: String(format: String(localized: "firstResultsFormat"), viewModel.plan.firstResults)
            )
            DescriptionText(
                icon: .budget,
                title: String(format: String(localized: "budgetFormat"), viewModel.plan.budget.description)
            )
            DescriptionText(
                icon: .result,
                title: String(format: String(localized: "resultFormat"), viewModel.plan.result)
            )
            DoneProgress(percentage: viewModel.plan.progress)
            Divider()
        }
    }

    private func DescriptionText(icon: ImageResource, title: String) -> some View {
        HStack(alignment: .top, spacing: 6.fitW) {
            Image(icon)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(title)
                .font(.system(size: 15.fitW))
                .foregroundStyle(.grayD1D1D6)
                .frame(minHeight: 24.fitW)
        }
    }

    private func Divider() -> some View {
        Rectangle()
            .fill(.gray545456.opacity(0.34))
            .frame(maxWidth: .infinity)
            .frame(height: 1.fitW)
    }

    private func WeeksScrollView() -> some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(spacing: 6.fitW) {
                    ForEach(viewModel.plan.weeks, id: \.id) { week in
                        WeekButton(week) {
                            viewModel.didTapWeekButton(week)
                        }
                        .id(week.id)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        reader.scrollTo(viewModel.selectedWeek?.id, anchor: .center)
                    }
                }
                .onChange(of: viewModel.selectedWeek) { oldValue, newValue in
                    guard oldValue?.id != newValue?.id else { return }
                    withAnimation(oldValue == nil ? nil : .easeInOut) {
                        reader.scrollTo(newValue?.id, anchor: .center)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .scrollClipDisabled()
        }
    }

    private func WeekButton(_ week: Project.Plan.Week, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            let isLocked = viewModel.lockedWeeks.contains { $0.id == week.id }
            let isSelected = viewModel.selectedWeek?.id == week.id
            HStack(spacing: 4.fitW) {
                if isLocked {
                    Image(.crownYellow)
                        .resizable()
                        .frame(width: 18.fitW, height: 18.fitW)
                }
                Text(String(format: String(localized: "shortWeekFormat"), week.number))
                    .font(.system(size: 13.fitW, weight: .semibold))
                    .foregroundStyle(
                        isSelected
                        ? .white
                        : (isLocked ? .yellowFFCC00 : .grayD1D1D6)
                    )
            }
            .frame(height: 36.fitW)
            .padding(.horizontal, 16.fitW)
            .background(
                isSelected
                ? .blue007AFF
                : (isLocked ? .yellowFFCC00.opacity(0.12) : .gray787880.opacity(0.12))
            )
            .clipShape(.capsule)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func StepButton(_ step: Project.Plan.Step) -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Button {
                viewModel.didTapStepButton(step)
            } label: {
                HStack(alignment: .top, spacing: .zero) {
                    Image(step.isCompleted ? .checkboxCircleSelectedYellow : .checkboxCircleUnselected)
                        .resizable()
                        .frame(width: 24.fitW, height: 24.fitW)

                    Text(step.title)
                        .font(.system(size: 15.fitW))
                        .foregroundStyle(.grayD1D1D6)
                        .frame(minHeight: 24.fitW)
                        .padding(.horizontal, 6.fitW)
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: step.title)

                    Spacer(minLength: .zero)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .hapticFeedback()

            StepMenuButton(step)
        }
    }

    private func StepMenuButton(_ step: Project.Plan.Step) -> some View {
        Button {
            viewModel.didTapStepMenuButton(step)
        } label: {
            Image(.menu)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
        .confirmationDialog(
            String(localized: "stepMenuDialogTitle"),
            isPresented: Binding(
                get: { viewModel.stepToMenu == step },
                set: {
                    if !$0 {
                        viewModel.stepToMenu = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "askAIAssistant")) {
                viewModel.didTapAskAssistantStepButton()
            }
            Button(String(localized: "rename")) {
                viewModel.didTapRenameStepButton()
            }
            Button(String(localized: "delete"), role: .destructive) {
                viewModel.didTapDeleteStepButton()
            }
            Button(String(localized: "cancel"), role: .cancel) {}
        } message: {
            if let step = viewModel.stepToMenu {
                Text(step.title)
            }
        }
    }

    private func AddStepButton() -> some View {
        Button(action: viewModel.didTapAddStepButton) {
            HStack(spacing: 4.fitW) {
                Image(.plusCircle)
                    .resizable()
                    .frame(width: 24.fitW, height: 24.fitW)

                Text(String(localized: "addNewOwnStep"))
                    .font(.system(size: 15.fitW))
                    .foregroundStyle(.blue007AFF)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func AskAssistantButton() -> some View {
        Button(action: viewModel.didTapAskAssistantButton) {
            HStack(spacing: 6.fitW) {
                Image(.chatAura)
                    .resizable()
                    .frame(width: 22.fitW, height: 22.fitW)

                Text(String(localized: "needHelpWithPlanAskAIAssistant"))
                    .multilineMinimumScale()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 13.fitW, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 46.fitW)
            .padding(.horizontal, 12.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Capsule()
                    .fill(.gray787880.opacity(0.12))
                    .blur(radius: 30.fitW)
                    .clipped()
            }
            .overlay {
                Capsule()
                    .strokeBorder(.gray545456.opacity(0.34), lineWidth: 1.fitW)
            }
            .clipShape(.capsule)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
        .transition(.opacity)
        .opacity(viewModel.isWellDone ? 0 : 1)
    }

    private func WellDoneView() -> some View {
        VStack(alignment: .center, spacing: .zero) {
            LottieView(animation: .named("well-done"))
                .playing(loopMode: .playOnce)
                .resizable()
                .frame(width: 150.fitW, height: 150.fitW)

            Text(String(localized: "wellDone"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16.fitW)
                .multilineTextAlignment(.center)

            Text(String(localized: "wellDoneDescription"))
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .transition(.blurReplace.combined(with: .opacity))
    }

    private func ViewPlanButton() -> some View {
        PrimaryButton(title: String(localized: "viewPlan"), onTap: viewModel.didTapViewPlanButton)
            .transition(.opacity)
            .opacity(viewModel.isWellDone ? 1 : 0)
    }

    private func PaywallCover() -> some View {
        PaywallView(viewModel: PaywallViewModel(
            storeManager: ServiceLayer.storeManager,
            networkMonitor: ServiceLayer.networkMonitor,
            analyticsManager: ServiceLayer.analyticsManager,
            placement: .stepTree
        ))
    }
}
