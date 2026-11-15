//
//  BriefCategoryPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefCategoryPage: View {

    // MARK: - Public Properties

    let selectedCategory: Project.Brief.Category?
    let categories: [Project.Brief.Category]
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool
    let onSelect: (Project.Brief.Category) -> Void

    // MARK: - Private Properties

    @State private var isSelectionEnabled = false
    @State private var keyboardHeight: CGFloat = .zero
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 18.fitW) {
            if needsReveal {
                WordRevealText(
                    text: title,
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(title)
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                CategoriesScrollView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                isSelectionEnabled = false
                topPadding = 256.fitH
            } else {
                isSelectionEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            transitionTask?.cancel()
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != nil
        }
        .onChangeKeyboardHeight { newValue in
            guard keyboardHeight != newValue else { return }
            keyboardHeight = newValue
        }
    }

    // MARK: - Views

    private var title: String {
        BriefLocalization.text(en: "What do you want to improve?", ru: "Что ты хочешь улучшить?")
    }

    private func CategoriesScrollView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12.fitW) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(category)
                }
            }
            .animation(.easeInOut, value: selectedCategory)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(.top, 14.fitW, for: .scrollContent)
        .contentMargins(
            .bottom,
            selectedCategory == nil
                ? 16.fitW
                : keyboardHeight > .zero ? 84.fitW : 115.fitW,
            for: .scrollContent
        )
    }

    private func CategoryButton(_ category: Project.Brief.Category) -> some View {
        let isSelected = category == selectedCategory

        return Button {
            onSelect(category)
        } label: {
            VStack(alignment: .leading, spacing: 4.fitW) {
                Text(category.title)
                    .font(.system(size: 17.fitW, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(category.subtitle)
                    .font(.system(size: 13.fitW))
                    .foregroundStyle(.gray8E8E93)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20.fitW)
            .padding(.vertical, 16.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .overlay {
                RoundedRectangle(cornerRadius: 16.fitW)
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isSelectionEnabled = true
            }
        }
    }
}
