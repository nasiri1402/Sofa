//
//  OnboardingNamePage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingNamePage: View {

    // MARK: - Public Properties

    @Binding var nameInput: String
    let onFinish: () -> Void

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var keyboardHeight: CGFloat = .zero

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            TitleText()
            NameTextField()
            Spacer()
        }
        .padding(16.fitW)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .transition(.opacity)
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            isFocused = false
        }
        .onChange(of: nameInput.isEmpty) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if !newValue {
                onFinish()
            }
        }
        .onChangeKeyboardHeight { newValue in
            guard newValue != keyboardHeight else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
        }
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(String(localized: "whatIsYourName"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func NameTextField() -> some View {
        TextField(String(localized: "enterYourName"), text: $nameInput)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .focused($isFocused)
            .frame(height: 22.fitW)
    }
}
