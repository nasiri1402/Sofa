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

    // MARK: - Private Properties

    @Environment(\.isTabBarHidden) private var isTabBarHidden

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
        .navigationBarLeadingButton(icon: .back) {
            isTabBarHidden.wrappedValue = false
            viewModel.didTapNavigationBarLeadingButton()
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
            viewModel.didViewAppear()
        }
        .fullScreenCover(isPresented: $viewModel.isPaywallPresented) {
            PaywallCover()
        }
        .fullScreenCover(isPresented: $viewModel.isGiftPaywallPresented) {
            GiftPaywallCover()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func GeneratorBar() -> some View {
        HStack {
            // TODO: для первой версии решили скрыть изменение входных данных проекта
            GeneratorButton(
                icon: .changeInput,
                title: String(localized: "changeInput").lowercased(),
                onTap: viewModel.didTapChangeInputButton
            )
            .hidden()
            Spacer()
            GeneratorButton(
                icon: .generateMore,
                title: String(localized: "generateOneMore").lowercased(),
                onTap: viewModel.didTapGenerateMoreButton
            )
            .confirmationDialog(
                String(localized: "сhooseDfficultyDialogTitle"),
                isPresented: $viewModel.isDifficultyDialogPresented,
                titleVisibility: .visible
            ) {
                Button(String(localized: "easy")) {
                    viewModel.didTapDifficultyDialogButton(.easy)
                }
                Button(String(localized: "average")) {
                    viewModel.didTapDifficultyDialogButton(.average)
                }
                Button(String(localized: "difficult")) {
                    viewModel.didTapDifficultyDialogButton(.difficult)
                }
                Button(String(localized: "cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "chooseDifficultyDialogMessage"))
            }
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

    private func GiftPaywallCover() -> some View {
        GiftPaywallView(viewModel: GiftPaywallViewModel(
            analyticsManager: ServiceLayer.analyticsManager,
            storeManager: ServiceLayer.storeManager
        ))
    }
}
