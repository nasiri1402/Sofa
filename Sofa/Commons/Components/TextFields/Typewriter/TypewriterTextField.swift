//
//  TypewriterTextField.swift
//  Sofa
//
//  Created by dukes on 11/11/25.
//

import SwiftUI

struct TypewriterTextField: View {

    // MARK: - Public Properties

    @Binding var text: String
    let placeholder: String
    let typewriterOptions: [String]
    @FocusState.Binding var isFocused: Bool

    // MARK: - Private Properties

    private let typingInterval = 0.1
    private let pauseInterval = 1

    @State private var typewriterText = ""
    @State private var index = 0

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder + typewriterText)
                    .font(.system(size: 17.fitW))
                    .foregroundStyle(.gray8E8E93)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsHitTesting(false)
            }

            TextField(
                "",
                text: $text,
                axis: .vertical
            )
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .focused($isFocused)
            .lineLimit(1...7)
        }
        .frame(maxWidth: .infinity, minHeight: 72.fitW, alignment: .topLeading)
        .task(id: text.isEmpty) {
            guard text.isEmpty else { return }
            await typeLoop()
        }
    }

    // MARK: - Private Methods

    private func typeLoop() async {
        while text.isEmpty {
            let option = typewriterOptions[index]
            for char in option {
                guard text.isEmpty else {
                    typewriterText.removeAll()
                    return
                }
                typewriterText.append(char)
                try? await Task.sleep(for: .seconds(typingInterval))
            }
            try? await Task.sleep(for: .seconds(pauseInterval))
            typewriterText.removeAll()
            index = (index + 1) % typewriterOptions.count
        }
    }
}
