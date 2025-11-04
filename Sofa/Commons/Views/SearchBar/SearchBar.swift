//
//  SearchBar.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct SearchBar: View {

    // MARK: - Public Properties

    @Binding var query: String
    var placeholder: String = String(localized: "search")
    @FocusState.Binding var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: .zero) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 20.fitW, height: 20.fitW)
                .foregroundStyle(.gray787880.opacity(0.12))

            TextField(placeholder, text: $query)
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white)
                .focused($isFocused)
                .tint(.blue007AFF)
                .autocorrectionDisabled()
                .padding(.horizontal, 8.fitW)

            Spacer(minLength: .zero)

            CancelButton()
                .opacity(query.isEmpty ? 0 : 1)
        }
        .frame(height: 36.fitW)
        .padding(.horizontal, 8.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10.fitW))
        .animation(.easeInOut, value: isFocused)
        .animation(.easeInOut, value: query.isEmpty)
    }

    // MARK: - Views

    private func CancelButton() -> some View {
        Button {
            query.removeAll()
            isFocused = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 20.fitW, height: 20.fitW)
                .foregroundStyle(.gray787880.opacity(0.4))
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
