//
//  OnboardingAboutUsOtherPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct OnboardingAboutUsOtherPage: View {

    // MARK: - Public Properties

    @Binding var otherSourceInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool

    // MARK: - Private Properties

    @FocusState private var isFocused

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            Text(String(localized: "howDidYouHearAboutUs"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            OtherSourceTextField()
                .transition(.opacity)
                .animation(.easeInOut, value: otherSourceInput )
                .transition(.move(edge: .bottom).combined(with: .opacity))

            Spacer(minLength: .zero)
        }
        .padding(.top, 72.fitW)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = otherSourceInput.isEmpty
            }
        }
        .onDisappear {
            isFocused = false
        }
        .onChange(of: otherSourceInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.isEmpty
        }
    }

    // MARK: - Views

    private func OtherSourceTextField() -> some View {
        TextField(
            String(localized: "yourAnswer"),
            text: $otherSourceInput,
            axis: .vertical
        )
        .font(.system(size: 17.fitW))
        .foregroundStyle(.grayE5E5EA)
        .autocorrectionDisabled()
        .focused($isFocused)
        .lineLimit(7)
        .transition(.opacity)
        .onAppear {
            isFocused = true
        }
    }
}
