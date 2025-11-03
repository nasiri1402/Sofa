//
//  PrimaryButton.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct PrimaryButton: View {

    // MARK: - Public Properties

    let title: String
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .multilineMinimumScale()
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12.fitW)
                .frame(height: 52.fitW)
                .background(.blue007AFF)
                .clipShape(.rect(cornerRadius: 12.fitW))
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
