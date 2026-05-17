//
//  ChatView.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import SwiftUI

struct ChatView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: ChatViewModel

    // MARK: - Private Properties

    @Environment(\.isTabBarHidden) private var isTabBarHidden
    @FocusState private var isInputFocused: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            ScrollViewReader { reader in
                ScrollView {
                    VStack(spacing: .zero) {
                        GreetingView()
                            .padding(.top, viewModel.messages.isEmpty ? 52.fitW : 24.fitW)
                            .padding(.bottom, viewModel.messages.isEmpty ? .zero : 32.fitW)

                        if viewModel.messages.isEmpty {
                            Spacer(minLength: 180.fitW)
                        } else {
                            LazyVStack(spacing: 12.fitW) {
                                ForEach(viewModel.messages, id: \.id) { message in
                                    MessageBubble(message)
                                        .id(message.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16.fitW)
                    .padding(.bottom, 16.fitW)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    ComposerView()
                        .padding(.horizontal, 16.fitW)
                        .padding(.top, 8.fitW)
                        .padding(.bottom, 16.fitW)
                        .background(.black090909)
                }
                .onAppear {
                    reader.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
                .onChange(of: viewModel.messages.count) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    withAnimation {
                        reader.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "aiAssistant"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarLeadingButton(icon: .timeArrow) {
            viewModel.didTapNavigationBarLeadingButton()
        }
        .navigationBarTrailingButton(icon: .cross) {
            viewModel.didTapNavigationBarTrailingButton()
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .onAppear {
            isTabBarHidden.wrappedValue = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isInputFocused = true
            }
        }
    }

    // MARK: - Views

    private func GreetingView() -> some View {
        VStack(spacing: 16.fitW) {
            Image(.chatAura)
                .resizable()
                .frame(width: 100.fitW, height: 100.fitW)
                .padding(.bottom, 9.fitW)

            Text(String(
                format: String(localized: "chatGreetingFormat"),
                viewModel.profile?.name ?? ""
            ))
            .multilineMinimumScale()
            .multilineTextAlignment(.center)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)

            Text( String(localized: "chatGreetingDescription"))
                .multilineMinimumScale(lineLimit: 2)
                .multilineTextAlignment(.center)
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private func MessageBubble(_ message: Project.Plan.Chat.Message) -> some View {
        HStack {
            if !message.isFromUser {
                BubbleText(message)
                Spacer(minLength: 50.fitW)
            } else {
                Spacer(minLength: 50.fitW)
                BubbleText(message)
            }
        }
    }

    private func BubbleText(_ message: Project.Plan.Chat.Message) -> some View {
        Text(.init(message.text))
            .font(.system(size: 15.fitW))
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12.fitW)
            .background(message.isFromUser ? .blue007AFF : .clear)
            .clipShape(.rect(cornerRadius: 20.fitW))
    }

    private func ComposerView() -> some View {
        HStack(alignment: .bottom, spacing: 8.fitW) {
            TextField( String(localized: "writeHere"), text: $viewModel.messageInput, axis: .vertical)
                .focused($isInputFocused)
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white)
                .tint(.blue007AFF)
                .lineLimit(1 ... 4)
                .padding(.leading, 16.fitW)
                .padding(.vertical, 14.fitW)

            Button(action: viewModel.didTapSendButton) {
                Image(.arrowRight)
                    .resizable()
                    .rotationEffect(.degrees(-90))
                    .frame(width: 16.fitW, height: 16.fitW)
                    .foregroundStyle(.white)
                    .frame(width: 36.fitW, height: 36.fitW)
                    .background(viewModel.canSendMessage ? .blue007AFF : .black090909)
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSendMessage)
            .padding(.trailing, 6.fitW)
            .padding(.bottom, 6.fitW)
        }
        .frame(minHeight: 48.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 24.fitW))
        .overlay {
            RoundedRectangle(cornerRadius: 24.fitW)
                .stroke(.gray545456.opacity(0.34), lineWidth: 1)
        }
    }
}
