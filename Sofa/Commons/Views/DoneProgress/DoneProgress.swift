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
            GeometryReader { geometry in
                Capsule()
                    .fill(.gray3C3C43.opacity(0.6))
                    .frame(height: 8.fitW)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(percentage >= 1 ? .green34C759 : .blue007AFF)
                            .frame(width: geometry.size.width * percentage, height: 8.fitW)
                            .animation(.easeInOut(duration: 0.25), value: percentage)
                    }
            }
            .frame(height: 8.fitW)

            Text("\(Int(percentage * 100))% " + String(localized: "done").lowercased())
                .font(.system(size: 12.fitW))
                .foregroundColor(.gray8E8E93)
        }
    }
}
