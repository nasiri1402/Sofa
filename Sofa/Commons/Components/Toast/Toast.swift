//
//  Toast.swift
//  Sofa
//
//  Created by dukes on 6/3/26.
//

import SwiftUI

struct Toast: View {

    // MARK: - Style

    enum Style {
        case success

        var icon: ImageResource {
            switch self {
            case .success: .check
            }
        }

        var foregroundColor: ColorResource {
            switch self {
            case .success: .green34C759
            }
        }

        var overlayColor: Color {
            switch self {
            case .success: .green34C759.opacity(0.2)
            }
        }
    }

    // MARK: - Public Properties

    let style: Style
    let title: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12.fitW) {
            Image(style.icon)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(title)
                .font(.system(size: 16.fitW, weight: .semibold))
                .foregroundStyle(Color(style.foregroundColor))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24.fitW)
        .frame(height: 72.fitW)
        .background {
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .clipped()

                Capsule()
                    .fill(.gray787880.opacity(0.12))
                    .blur(radius: 30.fitW)
                    .clipped()

                Capsule()
                    .fill(style.overlayColor)
            }
        }
        .overlay {
            Capsule()
                .strokeBorder(.gray545456.opacity(0.34), lineWidth: 1.fitW)
        }
        .clipShape(.capsule)
    }
}

#Preview {
    ZStack {
        Color.black090909
            .ignoresSafeArea()

        Toast(
            style: .success,
            title: "Message copied to clipboard"
        )
        .padding(.horizontal, 24.fitW)
    }
}
