//
//  DoneProgress.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct DoneProgress: View {

    // MARK: - Public Properties

    /// от 0 до 1
    let percentage: Double

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8.fitW) {
            ProgressBar(percentage: percentage, isGreenCompleted: true)
            HStack(spacing: .zero) {
                Text(percentage, format: .percent.precision(.fractionLength(.zero)))
                    .font(.system(size: 12.fitW))
                    .foregroundColor(.gray8E8E93)
                    .monospaced()
                    .contentTransition(.numericText())

                Text(" " + String(localized: "done").lowercased())
                    .font(.system(size: 12.fitW))
                    .foregroundColor(.gray8E8E93)
            }
            .animation(.easeInOut, value: percentage)
        }
    }
}
