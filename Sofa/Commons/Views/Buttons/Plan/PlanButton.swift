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
                    DifficultyStepsView()
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

    private func DifficultyStepsView() -> some View {
        HStack(spacing: 6.fitW) {
            Text(plan.difficulty.name)
                .font(.system(size: 13.fitW))
                .foregroundStyle(Color(plan.difficulty.color))

            Image(.arrowRight)
                .resizable()
                .frame(width: 14.fitW, height: 14.fitW)

            Text(String(format: String(localized: "stepsPluralFormat"), plan.steps.count))
                .font(.system(size: 13.fitW))
                .foregroundStyle(.gray8E8E93)

            Spacer(minLength: .zero)
        }
        .frame(height: 18.fitW)
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

            Text(plan.result)
                .font(.system(size: 13.fitW))
                .foregroundStyle(.grayE5E5EA)
        }
    }
}
