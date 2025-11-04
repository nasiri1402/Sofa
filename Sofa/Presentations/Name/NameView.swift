//
//  NameView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct NameView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: NameViewModel

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var keyboardHeight: CGFloat = .zero

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
                    NameTextField()
                    Spacer(minLength: .zero)
                    SaveButton()
                        .padding(.bottom, keyboardHeight > .zero ? .zero : 31.fitW)
                }
                .padding(16.fitW)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .onChangeKeyboardHeight { newValue in
            guard newValue != keyboardHeight else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
        }
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
        Text(String(localized: "whatIsYourName"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func NameTextField() -> some View {
        TextField(String(localized: "enterYourName"), text: $viewModel.nameInput)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .focused($isFocused)
            .frame(height: 22.fitW)
    }

    private func SaveButton() -> some View {
        PrimaryButton(title: String(localized: "saveChanges"), onTap: viewModel.didTapSaveButton)
    }
}
