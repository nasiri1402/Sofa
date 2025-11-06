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
    var subtitle: String?
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue007AFF
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .zero) {
                Text(title)
                    .multilineMinimumScale()
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(foregroundColor)
                    .frame(height: 20.fitW)

                if let subtitle {
                    Text(subtitle)
                        .multilineMinimumScale()
                        .font(.system(size: 11.fitW))
                        .foregroundStyle(foregroundColor.opacity(0.8))
                        .frame(height: 13.fitW)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12.fitW)
            .frame(height: 52.fitW)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 12.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
