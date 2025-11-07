//
//  BriefResultOptionPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefResultOptionPage: View {

    // MARK: - Public Properties

    @Binding var goalOptionInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            Text(String(localized: "whatDoesResultMeanToYou"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            OptionTextField()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: isPreviousEnabled)

            Spacer()
        }
        .padding(.top, 72.fitW)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .ignoresSafeArea(.keyboard)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
            isPreviousEnabled = true
        }
        .onDisappear {
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: goalOptionInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.isEmpty
        }
    }

    // MARK: - Views

    private func OptionTextField() -> some View {
        TextField(
            String(localized: "noteYourEndGoals"),
            text: $goalOptionInput,
            axis: .vertical
        )
        .font(.system(size: 17.fitW))
        .foregroundStyle(.grayE5E5EA)
        .autocorrectionDisabled()
        .focused($isFocused)
        .lineLimit(7)
    }
}
