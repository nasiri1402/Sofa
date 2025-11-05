//
//  InProcessView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct InProcessView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: InProcessViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(spacing: 16.fitW) {
                SegmentPicker()
                    .padding(.horizontal, 16.fitW)

                if let emptyState = viewModel.emptyState {
                    EmptyStateView(emptyState)
                        .padding(.top, 85.fitW)
                        .padding(.horizontal, 16.fitW)
                }
                Spacer(minLength: .zero)
            }
            .padding(.vertical, 24.fitW)
        }
        .navigationTitle(String(localized: "inProcess"))
        .navigationBarTitleDisplayMode(.large)
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

    private func EmptyStateView(_ state: InProcessModel.EmptyState) -> some View {
        VStack(alignment: .center, spacing: .zero) {
            // TODO: Временная иконка, нужна лотти анимация тут
            Image(systemName: "globe")
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
        .transition(.blurReplace.combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.emptyState)
    }
}
