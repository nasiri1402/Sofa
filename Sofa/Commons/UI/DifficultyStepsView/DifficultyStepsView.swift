//
//  DifficultyStepsView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct DifficultyStepsView: View {

    // MARK: - Public Properties

    let difficulty: Project.Plan.Difficulty
    let steps: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6.fitW) {
            Text(difficulty.name)
                .font(.system(size: 13.fitW))
                .foregroundStyle(Color(difficulty.color))

            Image(.arrowRight)
                .resizable()
                .frame(width: 14.fitW, height: 14.fitW)

            Text(String(format: String(localized: "stepsPluralFormat"), steps))
                .font(.system(size: 13.fitW))
                .foregroundStyle(.gray8E8E93)

            Spacer(minLength: .zero)
        }
        .frame(height: 18.fitW)
    }
}
