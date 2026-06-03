//
//  Toast.swift
//  Sofa
//
//  Created by dukes on 6/3/26.
//

import SwiftUI

struct Toast: View {

    // MARK: - Public Properties

    let item: ToastItem

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6.fitW) {
            Image(item.style.icon)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(item.title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 13.fitW, weight: .semibold))
                .foregroundStyle(item.style.foregroundColor)
                .frame(maxWidth: 260.fitW, alignment: .leading)
                .layoutPriority(1)
        }
        .padding(12.fitW)
        .fixedSize(horizontal: true, vertical: true)
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
                    .fill(item.style.backgroundColor)
                    .clipped()
            }
        }
        .overlay {
            Capsule()
                .strokeBorder(.gray545456.opacity(0.34), lineWidth: 1.fitW)
        }
        .clipShape(.capsule)
    }
}

// MARK: - ToastItem

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    var style: Style = .success
    let title: String
}

extension ToastItem {

    // MARK: - Style

    enum Style: Equatable {
        case success

        var icon: ImageResource {
            switch self {
            case .success: .check
            }
        }

        var foregroundColor: Color {
            switch self {
            case .success: .green34C759
            }
        }

        var backgroundColor: Color {
            switch self {
            case .success: .green34C759.opacity(0.2)
            }
        }
    }
}
