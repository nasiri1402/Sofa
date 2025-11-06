//
//  PlanButton.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct PlanButton: View {

    // MARK: - Public Properties

    let plan: Project.Plan
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12.fitW) {
                VStack(alignment: .leading, spacing: 8.fitW) {
                    TitleText()
                    DifficultyStepsView(difficulty: plan.difficulty, steps: plan.allSteps.count)
                }
                Divider()
                ResultView()
                DoneProgress(percentage: plan.progress)
            }
            .padding(20.fitW)
            .background(.gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(plan.emoji + " " + plan.title)
            .font(.system(size: 16.fitW, weight: .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .frame(height: 21.fitW)
    }

    private func Divider() -> some View {
        Rectangle()
            .fill(.gray545456.opacity(0.34))
            .frame(maxWidth: .infinity)
            .frame(height: 1.fitW)
    }

    private func ResultView() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.result)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .padding(.trailing, 8.fitW)

            Text(String(format: String(localized: "resultFormat"), plan.result))
                .font(.system(size: 13.fitW))
                .foregroundStyle(.grayE5E5EA)
                .frame(minHeight: 24.fitW)
        }
    }
}
