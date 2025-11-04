//
//  GenderView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct GenderView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: GenderViewModel

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

                VStack(alignment: .leading, spacing: 32.fitW) {
                    TitleText()

                    VStack(alignment: .leading, spacing: 12.fitW) {
                        ForEach(viewModel.genders, id: \.self) { gender in
                            GenderButton(gender)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.selectedGender)

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
        Text(String(localized: "whatShouldICallYou"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func GenderButton(_ gender: Profile.Gender) -> some View {
        Button {
            viewModel.didTapGenderButton(gender)
        } label: {
            HStack(spacing: .zero) {
                Text(viewModel.profile?.name ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)

                Text(" (" + gender.name + ")")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .lineLimit(1)
            .padding(.horizontal, 20.fitW)
            .frame(height: 48.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray787880.opacity(0.12))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(gender == viewModel.selectedGender ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SaveButton() -> some View {
        PrimaryButton(title: String(localized: "saveChanges"), onTap: viewModel.didTapSaveButton)
    }
}
