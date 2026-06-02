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
    private let scrollBottomID = "scrollBottomID"

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
                            Spacer(minLength: .zero)
                        } else {
                            MessagesList()
                        }
                        Color.black
                            .opacity(0.001)
                            .frame(height: 1)
                            .id(scrollBottomID)
                    }
                    .animation(.easeInOut, value: viewModel.messages.isEmpty)
                    .padding(.horizontal, 16.fitW)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(viewModel.messages.isEmpty ? .basedOnSize : .automatic)
                .contentMargins(.top, 24.fitW, for: .scrollContent)
                .contentMargins(.bottom, 16.fitW, for: .scrollContent)
                .safeAreaInset(edge: .bottom) {
                    ComposerView()
                        .padding(16.fitW)
                }
                .onAppear {
                    scrollToBottom(reader, isAnimated: false)
                }
                .onChange(of: viewModel.messages.count) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    if newValue > .zero {
                        scrollToBottom(reader)
                    }
                }
                .onChange(of: viewModel.isSending) { oldValue, newValue in
                    guard oldValue != newValue, !viewModel.messages.isEmpty else { return }
                    scrollToBottom(reader)
                }
                .onChange(of: isInputFocused) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    if newValue, !viewModel.messages.isEmpty {
                        scrollToBottom(reader)
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
        .transition(.blurReplace.combined(with: .opacity))
    }

    private func MessagesList() -> some View {
        LazyVStack(spacing: 12.fitW) {
            ForEach(viewModel.messages, id: \.id) { message in
                MessageView(message)
                    .id(message.id)
            }
            if let sendingState = viewModel.sendingState {
                SendingText(sendingState)
                    .padding(.top, 12.fitW)
            }
        }
        .animation(.easeInOut, value: viewModel.messages.count)
        .animation(.easeInOut, value: viewModel.isSending)
        .animation(.easeInOut, value: viewModel.sendingState)
        .transition(.blurReplace.combined(with: .opacity))
    }

    @ViewBuilder
    private func MessageView(_ message: Project.Plan.Chat.Message) -> some View {
        if message.isFromUser {
            VStack(alignment: .leading, spacing: 8.fitW) {
                let context = viewModel.getContext(message) ?? ""
                if !context.isEmpty {
                    Button {
                        viewModel.didTapMessageContext(message)
                    } label: {
                        StepText(context, lineLimit: 3)
                    }
                    .buttonStyle(.plain)
                    .hapticFeedback()
                    .padding(.vertical, 6.fitW)
                }
                HStack(spacing: .zero) {
                    Spacer(minLength: 50.fitW)
                    BubbleText(message)
                }
            }
        } else {
            HStack(spacing: .zero) {
                BubbleText(message)
                Spacer(minLength: 50.fitW)
            }
        }
    }

    private func BubbleText(_ message: Project.Plan.Chat.Message) -> some View {
        Text(.init(message.text))
            .font(.system(size: 15.fitW))
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .frame(alignment: .leading)
            .padding(.vertical, 12.fitW)
            .padding(.horizontal, message.isFromUser ? 12.fitW : .zero)
            .background(message.isFromUser ? .blue007AFF : .clear)
            .clipShape(.rect(cornerRadius: 20.fitW))
    }

    private func ComposerView() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let step = viewModel.step {
                HStack(spacing: .zero) {
                    StepText(step.title, lineLimit: 1)
                    Spacer(minLength: 6.fitW)
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
            ZStack {
                RoundedRectangle(cornerRadius: 20.fitW)
                    .fill(.ultraThinMaterial)
                    .clipped()

                RoundedRectangle(cornerRadius: 20.fitW)
                    .fill(.gray787880.opacity(0.12))
                    .blur(radius: 30.fitW)
                    .clipped()
            }
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.step == nil)
        .animation(.easeInOut(duration: 0.25), value: viewModel.canSendMessage)
        .animation(.easeInOut(duration: 0.1), value: viewModel.messageInput.count)
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
                .frame(alignment: .leading)
        }
    }

    private func StepClearButton() -> some View {
        Button {
            isInputFocused = false
            viewModel.didTapStepClearButton()
        } label: {
            Image(.cross)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .foregroundStyle(.blue007AFF)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SendingText(_ state: ChatModel.SendingState) -> some View {
        Text(state.title + "...")
            .font(.system(size: 15.fitW))
            .foregroundStyle(.gray8E8E93)
            .overlay(alignment: .leading) {
                Text(state.title + "...")
                    .font(.system(size: 15.fitW))
                    .foregroundStyle(.white.opacity(0.75))
                    .shimmering()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity.combined(with: .blurReplace))
            .contentTransition(.numericText())
    }

    private func SendButton() -> some View {
        Button {
            isInputFocused = false
            viewModel.didTapSendButton()
        } label: {
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
    }

    // MARK: - Private Methods

    private func scrollToBottom(_ reader: ScrollViewProxy, isAnimated: Bool = true) {
        let onScroll = {
            reader.scrollTo(scrollBottomID, anchor: .bottom)
        }
        if isAnimated {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    onScroll()
                }
            }
        } else {
            DispatchQueue.main.async {
                onScroll()
            }
        }
    }
}
