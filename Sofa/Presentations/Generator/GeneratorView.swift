//
//  GeneratorView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct GeneratorView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: GeneratorViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                StoriesScrollView()
                    .padding(.top, 16.fitW)
                Spacer()
            }
            VStack {
                Spacer()
                GenerateButton()
                    .padding(16.fitW)
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .fullScreenCover(item: $viewModel.selectedStory) {
            StoriesCover($0)
        }
    }

    // MARK: - Views

    private func StoriesScrollView() -> some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 10.fitW) {
                    ForEach(viewModel.stories, id: \.self) { story in
                        Button {
                            viewModel.didTapStoryButton(story)
                            withAnimation {
                                reader.scrollTo(story, anchor: .center)
                            }
                        } label: {
                            Text(story.emoji + " " + story.title)
                                .foregroundStyle(.white)
                                .padding(20.fitW)
                                .frame(width: 160.fitW, height: 128.fitW, alignment: .topLeading)
                                .background(Color(story.color))
                                .clipShape(.rect(cornerRadius: 24.fitW))
                        }
                        .buttonStyle(.plain)
                        .hapticFeedback()
                        .tag(story)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 16.fitW, for: .scrollContent)
        }
    }

    private func GenerateButton() -> some View {
        PrimaryButton(title: String(localized: "startGeneration"), onTap: viewModel.didTapGenerateButton)
    }

    private func StoriesCover(_ story: GeneratorModel.Story) -> some View {
        NavigationStack {
            StoriesView(viewModel: StoriesViewModel(
                story: {
                    switch story {
                    case .green: .green
                    case .orange: .orange
                    case .red: .red
                    }
                }()
            ))
        }
    }
}
