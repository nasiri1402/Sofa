//
//  AgeView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct AgeView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: AgeViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    BackButton()
                    Spacer()
                }
                .padding(.top, 10.fitW)
                .padding(.leading, 16.fitW)

                VStack(alignment: .leading, spacing: .zero) {
                    TitleText()
                    AgesScrollView()
                        .padding(.top, 73.fitW)
                        .padding(.bottom, 30.fitW)

                    Spacer(minLength: .zero)
                    SaveButton()
                        .padding(.bottom, 31.fitW)
                }
                .padding(16.fitW)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
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
    }

    private func TitleText() -> some View {
        Text(String(localized: "howOldAreYou"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func AgesScrollView() -> some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    ForEach(viewModel.ages, id: \.self) { age in
                        AgeButton(age)
                            .id(age)
                    }
                }
                .animation(.easeInOut, value: viewModel.selectedAge)
                .onChange(of: viewModel.selectedAge) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    withAnimation(oldValue == nil ? nil : .default) {
                        reader.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func AgeButton(_ age: Int) -> some View {
        Button {
            viewModel.didTapAgeButton(age)
        } label: {
            let isSelected = age == viewModel.selectedAge
            Text(age.description + (age == viewModel.ages.last ? "+" : ""))
                .font(.system(size: isSelected ? 28.fitW : 22.fitW, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
                .frame(height: 34.fitW)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SaveButton() -> some View {
        PrimaryButton(title: String(localized: "saveChanges"), onTap: viewModel.didTapSaveButton)
    }
}
