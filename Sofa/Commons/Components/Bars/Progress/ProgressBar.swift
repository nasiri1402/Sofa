//
//  ProgressBar.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct ProgressBar: View {

    // MARK: - Public Properties

    /// от 0 до 1
    let percentage: Double
    let isGreenCompleted: Bool

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(.gray3C3C43.opacity(0.6))
                .frame(height: 8.fitW)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(percentage == 1 && isGreenCompleted ? .green34C759 : .blue007AFF)
                        .frame(width: geometry.size.width * percentage, height: 8.fitW)
                        .animation(.easeInOut, value: percentage)
                }
        }
        .frame(height: 8.fitW)
    }
}
