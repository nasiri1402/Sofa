//
//  GenerationResultView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct GenerationResultView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: GenerationResultViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16.fitW) {
                    GeneratorBar()
                    SummaryText()

                    LazyVStack(spacing: 12.fitW) {
                        ForEach(viewModel.project.plans, id: \.id) { plan in
                            PlanButton(plan: plan) {
                                viewModel.didTapPlanButton(plan)
                            }
                        }
                    }
                    .padding(.top, 16.fitW)
                }
                .padding(.horizontal, 16.fitW)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.vertical, 24.fitW, for: .scrollContent)
        }
        .navigationTitle(String(localized: "generationResult"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationBarLeadingButton(icon: .back, action: viewModel.didTapNavigationBarLeadingButton)
        .onAppear {
            viewModel.didViewAppear()
        }
        .fullScreenCover(isPresented: $viewModel.isPaywallPresented) {
            PaywallCover()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func GeneratorBar() -> some View {
        HStack {
            GeneratorButton(
                icon: .changeInput,
                title: String(localized: "changeInput").lowercased(),
                onTap: viewModel.didTapChangeInputButton
            )
            Spacer()
            GeneratorButton(
                icon: .generateMore,
                title: String(localized: "generateMore").lowercased(),
                onTap: viewModel.didTapGenerateMoreButton
            )
        }
    }

    private func GeneratorButton(
        icon: ImageResource,
        title: String,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 4.fitW) {
                Image(icon)
                    .resizable()
                    .frame(width: 20.fitW, height: 20.fitW)
                    .foregroundStyle(viewModel.isPro ? .blue007AFF : .yellowFFCC00)

                Text(title)
                    .font(.system(size: 13.fitW))
                    .foregroundStyle(viewModel.isPro ? .blue007AFF : .yellowFFCC00)
            }
            .frame(height: 34.fitW)
            .padding(.leading, 7.fitW)
            .padding(.trailing, 12.fitW)
            .background(viewModel.isPro ? .gray787880.opacity(0.12) : .yellowFFCC00.opacity(0.12))
            .clipShape(.rect(cornerRadius: 6.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SummaryText() -> some View {
        Text(viewModel.project.summary)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.gray8E8E93)
            .multilineTextAlignment(.leading)
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
