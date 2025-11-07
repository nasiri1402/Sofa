//
//  BriefTimeframePage.swift
//  Sofa
//
//  Created by dukes on 11/7/25.
//

import SwiftUI

struct BriefTimeframePage: View {

    // MARK: - Public Properties

    @Binding var selectedTimeframe: Project.Brief.Timeframe?
    let timeframes: [Project.Brief.Timeframe]
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @State private var phase: Phase = .one
    @State private var isSelectionEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 32.fitW) {
            if needsReveal {
                WordRevealText(
                    text: phase.text,
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: advanceToNextPhase
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "howMuchTimeIsNeeded"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    ForEach(timeframes, id: \.self) { timeframe in
                        TimeframeButton(timeframe)
                    }
                }
                .animation(.easeInOut, value: selectedTimeframe)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            if needsReveal {
                phase = .one
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
        .onChange(of: selectedTimeframe) { oldValue, newValue in
            guard oldValue != newValue else { return }
            isNextEnabled = newValue != nil
        }
    }

    // MARK: - Views

    private func TimeframeButton(_ timeframe: Project.Brief.Timeframe) -> some View {
        Button {
            selectedTimeframe = timeframe
        } label: {
            Text(timeframe.name)
                .multilineMinimumScale()
                .multilineTextAlignment(.center)
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20.fitW)
                .frame(height: 48.fitW)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.gray787880.opacity(0.12))
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                        .opacity(timeframe == selectedTimeframe ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    // MARK: - Private Methods

    @MainActor
    func advanceToNextPhase() {
        guard let next = nextPhase(after: phase) else {
            completeTitleReveal()
            return
        }
        phase = next
    }

    func nextPhase(after phase: Phase) -> Phase? {
        guard let index = Phase.allCases.firstIndex(of: phase) else { return nil }
        return Phase.allCases[safe: index + 1]
    }

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

// MARK: - Types

extension BriefTimeframePage {
    enum Phase: Int, CaseIterable {
        case one, two

        var text: String {
            switch self {
            case .one: String(localized: "coolLetsMoveOn")
            case .two: String(localized: "howMuchTimeIsNeeded")
            }
        }
    }
}
