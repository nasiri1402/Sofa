//
//  MyDataView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct MyDataView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: MyDataViewModel

    // MARK: - Private Properties

    @Environment(\.isTabBarHidden) private var isTabBarHidden

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 10.fitW) {
                    ForEach(viewModel.fields, id: \.self) { field in
                        FieldButton(field)
                    }
                }
                .padding(.horizontal, 16.fitW)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.vertical, 24.fitW, for: .scrollContent)
        }
        .animation(.easeInOut, value: viewModel.profile)
        .navigationTitle(String(localized: "myData"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarLeadingButton(icon: .back) {
            viewModel.didTapNavigationBarLeadingButton()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
            viewModel.didViewAppear()
        }
    }

    // MARK: - Views

    private func FieldButton(_ field: MyDataModel.Field) -> some View {
        Button {
            viewModel.didTapFieldButton(field)
        } label: {
            HStack(spacing: 6.fitW) {
                Text(field.title)
                    .font(.system(size: 16.fitW, weight: .semibold))
                    .foregroundStyle(.blue007AFF)

                Spacer(minLength: .zero)
                Text(viewModel.getFieldDetails(field))
                    .font(.system(size: 16.fitW))
                    .foregroundStyle(.gray8E8E93)
                    .lineLimit(1)
            }
            .padding(20.fitW)
            .background(.gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
