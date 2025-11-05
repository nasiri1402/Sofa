//
//  GeneratorView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI
import SwipeActions

struct GeneratorView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: GeneratorViewModel

    // MARK: - Private Properties

    @State private var swipeState: SwipeState = .untouched

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                StoriesScrollView()
                    .padding(.top, 16.fitW)

                VStack(alignment: .leading, spacing: 12.fitW) {
                    LatestGenerationsText()
                        .padding(.horizontal, 16.fitW)

                    ProjectScrollView()
                }
                .padding(.top, 24.fitW)
            }
            VStack {
                Spacer()
                GenerateButton()
                    .padding(16.fitW)
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .contentShape(.rect)
        .onTapGesture {
            swipeState = .swiped(UUID())
        }
        .onDisappear {
            swipeState = .swiped(UUID())
        }
        .onChange(of: viewModel.deleteTrigger) { _, _ in
            swipeState = .swiped(UUID())
        }
        .fullScreenCover(item: $viewModel.selectedStory) {
            StoriesCover($0)
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
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
                            swipeState = .swiped(UUID())
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

    private func LatestGenerationsText() -> some View {
        Text(String(localized: "latestGenerations"))
            .font(.system(size: 20.fitW, weight: .semibold))
            .foregroundStyle(.white)
            .frame(height: 25.fitW, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    private func ProjectScrollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 12.fitW) {
                ForEach(viewModel.projects, id: \.id) { project in
                    ProjectButton(project)
                        .addSwipeAction(edge: .trailing, state: $swipeState) {
                            Button {
                                viewModel.didTapDeleteProjectButton(project)
                            } label: {
                                RoundedRectangle(cornerRadius: 16.fitW)
                                    .fill(.redFF3B30)
                                    .frame(width: 64.fitW)
                                    .frame(maxHeight: .infinity)
                                    .overlay {
                                        Image(.trash)
                                            .resizable()
                                            .frame(width: 32.fitW, height: 32.fitW)
                                            .contentShape(.rect)
                                    }
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 16.fitW)
                        }
                        .id(project.id)
                        .transition(.opacity)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .contentMargins(.bottom, 84.fitW, for: .scrollContent)
    }

    private func ProjectButton(_ project: Project) -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.starsBlue)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .padding(.trailing, 6.fitW)

            Text(project.summary)
                .font(.system(size: 15.fitW))
                .foregroundStyle(.grayD1D1D6)
        }
        .padding(20.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 16.fitW))
        .contentShape(.rect)
        .onTapGesture {
            viewModel.didTapProjectButton(project)
            swipeState = .swiped(UUID())
        }
        .hapticFeedback()
    }

    private func GenerateButton() -> some View {
        PrimaryButton(title: String(localized: "startGeneration")) {
            viewModel.didTapGenerateButton()
            swipeState = .swiped(UUID())
        }
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
