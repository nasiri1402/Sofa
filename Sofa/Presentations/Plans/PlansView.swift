//
//  PlansView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Lottie
import SwiftUI

struct PlansView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: PlansViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                SegmentPicker()
                    .padding(.top, 24.fitW)
                    .padding(.bottom, 16.fitW)

                if let emptyState = viewModel.emptyState {
                    EmptyStateView(emptyState)
                        .padding(.top, 69.fitW)

                    Spacer(minLength: .zero)
                } else {
                    PlansScrollView()
                }
            }
            .padding(.horizontal, 16.fitW)
        }
        .navigationTitle(String(localized: "plans"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.didViewAppear()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func SegmentPicker() -> some View {
        Picker(String(""), selection: $viewModel.selectedSegment) {
            ForEach(viewModel.segments, id: \.self) { segment in
                let isSelected = segment == viewModel.selectedSegment
                Text(segment.title)
                    .font(.system(size: 13.fitW, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(.white)
                    .tag(segment.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .tint(.gray636366)
    }

    private func EmptyStateView(_ state: PlansModel.EmptyState) -> some View {
        VStack(alignment: .center, spacing: .zero) {
            LottieView(animation: .named("empty-state"))
                .looping()
                .resizable()
                .frame(width: 150.fitW, height: 150.fitW)

            Text(state.title)
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16.fitW)
                .multilineTextAlignment(.center)

            Text(state.description)
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .transition(.opacity)
    }

    private func PlansScrollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 12.fitW) {
                ForEach(viewModel.plans, id: \.id) { plan in
                    PlanButton(plan: plan) {
                        viewModel.didTapPlanButton(plan)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(.top, 8.fitW, for: .scrollContent)
        .contentMargins(.bottom, 16.fitW, for: .scrollContent)
    }
}
