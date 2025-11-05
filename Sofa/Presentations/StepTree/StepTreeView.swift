//
//  StepTreeView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct StepTreeView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: StepTreeViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    VStack(alignment: .leading, spacing: 6.fitW) {
                        TitleText()
                        DifficultyStepsView(
                            difficulty: viewModel.plan.difficulty,
                            steps: viewModel.plan.steps.count
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
                .padding(.horizontal, 16.fitW)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.vertical, 24.fitW, for: .scrollContent)
        }
        .navigationTitle(String(localized: "stepTree"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationBarLeadingButton(icon: .back, action: viewModel.didTapNavigationBarLeadingButton)
        .navigationBarTrailingButton(
            icon: viewModel.plan.isFavorite ? .like : .unlike,
            action: viewModel.didTapNavigationBarTrailingButton
        )
        .fullScreenCover(isPresented: $viewModel.isPaywallPresented) {
            PaywallCover()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(viewModel.plan.emoji + " " + viewModel.plan.title)
            .font(.system(size: 22.fitW, weight: .bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
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

    private func PaywallCover() -> some View {
        PaywallView(viewModel: PaywallViewModel(
            storeManager: ServiceLayer.storeManager,
            networkMonitor: ServiceLayer.networkMonitor,
            analyticsManager: ServiceLayer.analyticsManager,
            placement: .generationResult
        ))
    }
}
