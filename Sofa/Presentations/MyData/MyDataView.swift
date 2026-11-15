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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8.fitW))
            : AnyLayout(HStackLayout(spacing: 6.fitW))

        return Button {
            viewModel.didTapFieldButton(field)
        } label: {
            layout {
                Text(field.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.blue007AFF)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: .zero)
                }
                Text(viewModel.getFieldDetails(field))
                    .font(.callout)
                    .foregroundStyle(.gray8E8E93)
                    .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20.fitW)
            .background(.gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
