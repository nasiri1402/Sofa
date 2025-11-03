//
//  StoriesView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct StoriesView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: StoriesViewModel

    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            viewModel.story.color
                .ignoresSafeArea()

            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                    PageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()
                NextButton()
                    .padding(16.fitW)
            }
        }
        .navigationTitle(viewModel.pageCounter)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarLeadingButton(icon: .cross) {
            dismiss()
        }
        .onChange(of: viewModel.dismissTrigger) { _, _ in
            dismiss()
        }
    }

    // MARK: - Views

    private func PageView(_ page: StoriesModel.Page) -> some View {
        HStack(spacing: .zero) {
            VStack(alignment: .leading, spacing: 32.fitW) {
                Text(page.title.fullText)
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                ForEach(page.tips, id: \.self) { tip in
                    Text(tip.fullText)
                        .font(.system(size: 22.fitW, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: .zero)
            }
            Spacer(minLength: .zero)
        }
        .padding(.horizontal, 16.fitW)
        .padding(.vertical, 24.fitW)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func NextButton() -> some View {
        PrimaryButton(
            title: viewModel.currentPageIndex == viewModel.pages.count - 1
            ? String(localized: "tryItRightNow")
            : String(localized: "next"),
            foregroundColor: viewModel.story.color,
            backgroundColor: .white,
            onTap: viewModel.didTapNextButton
        )
    }
}
