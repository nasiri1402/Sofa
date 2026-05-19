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
                        if viewModel.messages.isEmpty {
                            GreetingView()
                                .transition(.blurReplace.combined(with: .opacity).combined(with: .scale))

                            Spacer(minLength: 100.fitW)
                        } else {
                            MessagesList()
                                .transition(.blurReplace.combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: viewModel.messages.isEmpty)
                    .padding(.horizontal, 16.fitW)
                    .padding(.bottom, 16.fitW)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .contentMargins(.top, 16.fitW, for: .scrollContent)
                .safeAreaInset(edge: .bottom) {
                    ComposerView()
                        .padding(16.fitW)
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
            isInputFocused = true
        }
        .contentShape(.rect)
        .onTapGesture {
            isInputFocused = false
        }
    }

    // MARK: - Views

    private func GreetingView() -> some View {
        VStack(spacing: .zero) {
            Image(.chatAura)
                .resizable()
                .frame(width: 100.fitW, height: 100.fitW)
                .padding(50.fitW)

            Text(String(
                format: String(localized: "chatGreetingFormat"),
                viewModel.profile?.name ?? ""
            ))
            .multilineMinimumScale()
            .multilineTextAlignment(.center)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .padding(.bottom, 16.fitW)

            Text( String(localized: "chatGreetingDescription"))
                .multilineMinimumScale(lineLimit: 2)
                .multilineTextAlignment(.center)
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private func MessagesList() -> some View {
        LazyVStack(spacing: 12.fitW) {
            ForEach(viewModel.messages, id: \.id) { message in
                MessageBubble(message)
                    .id(message.id)
            }
        }
        .animation(.easeInOut, value: viewModel.messages.count)
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
        VStack(alignment: .leading, spacing: 8.fitW) {
            let context = viewModel.getContext(message) ?? ""

            if !context.isEmpty {
                StepText(context, lineLimit: 3)
                    .padding(.vertical, 6.fitW)
            }
            Text(.init(message.text))
                .font(.system(size: 15.fitW))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(context.isEmpty ? 12.fitW : 10.fitW)
                .background(message.isFromUser ? .blue007AFF : .clear)
                .clipShape(.rect(cornerRadius: 20.fitW))
        }
    }

    private func ComposerView() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let step = viewModel.step {
                HStack(spacing: 6.fitW) {
                    StepText(step.title, lineLimit: 1)
                    StepClearButton()
                }
                .padding(6.fitW)
                .background(.blue007AFF.opacity(0.15))
                .clipShape(.capsule)
                .padding([.top, .horizontal], 6.fitW)
            }
            HStack(alignment: .bottom, spacing: 8.fitW) {
                TextField(String(localized: "writeHere"), text: $viewModel.messageInput, axis: .vertical)
                    .focused($isInputFocused)
                    .font(.system(size: 15.fitW))
                    .foregroundStyle(.white)
                    .tint(.blue007AFF)
                    .lineLimit(1 ... 4)
                    .padding(.leading, 15.fitW)
                    .padding(.vertical, 14.fitW)

                SendButton()
                    .padding(6.fitW)
            }
        }
        .frame(minHeight: 48.fitW)
        .background {
            RoundedRectangle(cornerRadius: 20.fitW)
                .fill(.gray787880.opacity(0.12))
                .blur(radius: 30.fitW)
                .clipped()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20.fitW)
                .strokeBorder(.gray545456.opacity(0.34), lineWidth: 1.fitW)
        }
        .clipShape(.rect(cornerRadius: 20.fitW))
        .contentShape(.rect)
        .onTapGesture {
            isInputFocused = true
        }
        .animation(.easeInOut, value: viewModel.step == nil)
    }

    private func StepText(_ context: String, lineLimit: Int) -> some View {
        HStack(spacing: 6.fitW) {
            Image(.reply)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(context)
                .font(.system(size: 13.fitW))
                .foregroundStyle(.blue007AFF)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func StepClearButton() -> some View {
        Button(action: viewModel.didTapStepClearButton) {
            Image(.cross)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .foregroundStyle(.blue007AFF)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SendButton() -> some View {
        Button(action: viewModel.didTapSendButton) {
            Image(.arrowTop)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .foregroundStyle(.white)
                .padding(6.fitW)
                .background(viewModel.canSendMessage ? .blue007AFF : .black)
                .clipShape(.circle)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(viewModel.canSendMessage)
        .animation(.easeInOut, value: viewModel.canSendMessage)
    }
}
