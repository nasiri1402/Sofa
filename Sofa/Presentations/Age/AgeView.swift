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
                TitleText()

                Spacer(minLength: .zero)

                AgePicker()
                    .padding(.bottom, 30.fitW)

                Spacer(minLength: .zero)
                SaveButton()
                    .padding(.bottom, 31.fitW)
            }
            .padding(16.fitW)
        }
        .navigationTitle(String(localized: "age"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarLeadingButton(icon: .back) {
            viewModel.didTapNavigationBarLeadingButton()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(String(localized: "howOldAreYou"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func AgePicker() -> some View {
        Picker(String(""), selection: $viewModel.selectedAge) {
            ForEach(viewModel.ages, id: \.self) { age in
                Text(
                    age == .zero
                    ? String(localized: "notSelected")
                    : age.description + (age == viewModel.ages.last ? "+" : "")
                )
                .font(.system(size: 24.fitW, weight: .semibold))
                .foregroundStyle(.white)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }

    private func SaveButton() -> some View {
        PrimaryButton(title: String(localized: "saveChanges"), onTap: viewModel.didTapSaveButton)
    }
}
