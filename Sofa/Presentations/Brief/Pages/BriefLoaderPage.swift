//
//  BriefLoaderPage.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Lottie
import SwiftUI

struct BriefLoaderPage: View {

    // MARK: - Public Properties

    @Binding var isPreviousEnabled: Bool

    // MARK: - Private Properties

    @State private var phase: Phase = .analyzing
    @State private var pool = Phase.allCases

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: .zero) {
                LottieView(animation: .named("generation-loading"))
                    .looping()
                    .resizable()
                    .frame(width: 150.fitW, height: 150.fitW)

                Text(String(localized: "generatingAllPossiblePaths"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 16.fitW)
                    .multilineTextAlignment(.center)

                WordRevealText(
                    text: phase.description,
                    font: .system(size: 17.fitW),
                    revealedColor: .white.opacity(0.4),
                    pauseAfterReveal: 3,
                    onFinished: advanceToNextPhase
                )
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: .zero)
            }
            .frame(maxWidth: .infinity)
            .transition(.blurReplace.combined(with: .opacity))
            .padding(.top, 170.fitW)
            .padding(.horizontal, 16.fitW)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDisabled(true)
        .onAppear {
            isPreviousEnabled = false
        }
    }

    // MARK: - Private Methods

    @MainActor
    func advanceToNextPhase() {
        phase = nextPhase(after: phase)
    }

    func nextPhase(after phase: Phase) -> Phase {
        // Если пул пуст, то восстанавливаем все варианты
        if pool.isEmpty {
            pool = Phase.allCases
        }
        // Исключаем текущее сообщение, чтобы не повторялось подряд
        guard let nextPhase = pool.filter({ $0 != phase }).randomElement() else { return phase }
        pool.removeAll { $0 == nextPhase }
        return nextPhase
    }
}

// MARK: - Types

extension BriefLoaderPage {
    typealias Phase = GenerationLoaderModel.Message
}
