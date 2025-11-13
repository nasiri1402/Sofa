//
//  BriefResultSubscribersPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefResultSubscribersPage: View {

    // MARK: - Public Properties

    @Binding var goalSubscribersInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var isInputEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "howManySubscribersDoYouWant"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "howManySubscribersDoYouWant"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isInputEnabled {
                SubscribersTextField()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .ignoresSafeArea(.keyboard)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            if needsReveal {
                isInputEnabled = false
                topPadding = 256.fitH
            } else {
                isInputEnabled = true
                topPadding = 72.fitW
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = goalSubscribersInput.isEmpty
                }
            }
        }
        .onDisappear {
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: goalSubscribersInput) { oldValue, newValue in
            defer { isNextEnabled = !goalSubscribersInput.isEmpty }
            guard oldValue != newValue else { return }
            let scalars = newValue.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
            let digits = String(scalars.map(Character.init))
            guard digits != newValue else { return }
            goalSubscribersInput = digits
        }
    }

    // MARK: - Views

    private func SubscribersTextField() -> some View {
        TextField(String("0"), text: $goalSubscribersInput)
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .focused($isFocused)
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isInputEnabled = true
            } completion: {
                isFocused = true
            }
        }
    }
}
