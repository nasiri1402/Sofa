//
//  BriefResultPage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefResultPage: View {

    // MARK: - Public Properties

    @Binding var goalMoneyInput: String?
    @Binding var goalSubscribersInput: String?
    @Binding var goalOptionInput: String?
    @Binding var selectedGoals: Set<Project.Brief.Goal>
    let goals: [Project.Brief.Goal]
    let isGoalMoneyHidden: Bool
    let isGoalSubscribersHidden: Bool
    let isGoalOptionHidden: Bool
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @FocusState private var isFocused
    @State private var isSelectionEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "whatDoesResultMeanToYou"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whatIsYourIdea"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                VStack(spacing: .zero) {
                    if !isGoalSubscribersHidden {
                        SubscribersTextField()
                            .transition(.opacity)

                    } else if !isGoalMoneyHidden {
                        MoneyTextField()
                            .transition(.opacity)

                    } else if !isGoalOptionHidden {
                        OptionTextField()
                            .transition(.opacity)

                    } else {
                        VStack(spacing: 32.fitW) {
                            Tip(text: String(localized: "selectMultipleAnswersOrWriteYourOwn"))
                            VStack(alignment: .leading, spacing: 12.fitW) {
                                ForEach(goals, id: \.self) { goal in
                                    GoalButton(goal)
                                }
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: selectedGoals)
                .animation(.easeInOut, value: goalMoneyInput == nil)
                .animation(.easeInOut, value: goalSubscribersInput == nil)
                .animation(.easeInOut, value: goalOptionInput == nil)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .contentShape(.rect)
        .onTapGesture {
            isFocused = false
        }
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
            isFocused = false
            transitionTask?.cancel()
        }
        .onChange(of: selectedGoals) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !newValue.isEmpty
        }
        .onChange(of: goalMoneyInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !(newValue ?? "").isEmpty
        }
        .onChange(of: goalSubscribersInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !(newValue ?? "").isEmpty
        }
        .onChange(of: goalOptionInput) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = !(newValue ?? "").isEmpty
        }
    }

    // MARK: - Views

    private func GoalButton(_ goal: Project.Brief.Goal) -> some View {
        Button {
            guard !selectedGoals.contains(goal) else {
                selectedGoals.remove(goal)
                return
            }
            if goal == .option {
                selectedGoals.removeAll()
            } else if selectedGoals.contains(.option) {
                selectedGoals.remove(.option)
            }
            selectedGoals.insert(goal)
        } label: {
            HStack(spacing: 6.fitW) {
                if selectedGoals.contains(goal), goal != .option {
                    Image(.checkboxRectSelectedWhite)
                        .resizable()
                        .frame(width: 20.fitW, height: 20.fitW)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                Text(goal.name)
                    .multilineMinimumScale()
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20.fitW)
            .frame(height: 48.fitW)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.gray787880.opacity(0.12))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(selectedGoals.contains(goal) ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }


    private func MoneyTextField() -> some View {
        HStack(spacing: .zero) {
            Text(verbatim: "$ ")
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white)

            TextField(
                String("0"),
                text: Binding(
                    get: { goalMoneyInput?.description ?? "" },
                    set: { goalMoneyInput = $0.filter(\.isNumber) }
                )
            )
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onAppear {
                goalSubscribersInput = nil
                isFocused = true
            }
        }
    }

    private func SubscribersTextField() -> some View {
        HStack(spacing: .zero) {
            Text(verbatim: "$ ")
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white)

            TextField(
                String("0"),
                text: Binding(
                    get: { goalSubscribersInput?.description ?? "" },
                    set: { goalSubscribersInput = $0.filter(\.isNumber) }
                )
            )
            .font(.system(size: 17.fitW))
            .foregroundStyle(.grayE5E5EA)
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
        }
    }

    private func OptionTextField() -> some View {
        TextField(
            String(localized: "noteYourEndGoals"),
            text: Binding(get: { goalOptionInput ?? "" }, set: { goalOptionInput = $0 }),
            axis: .vertical
        )
        .font(.system(size: 17.fitW))
        .foregroundStyle(.grayE5E5EA)
        .autocorrectionDisabled()
        .focused($isFocused)
        .lineLimit(7)
        .onAppear {
            isFocused = true
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isSelectionEnabled = true
            }
        }
    }
}
