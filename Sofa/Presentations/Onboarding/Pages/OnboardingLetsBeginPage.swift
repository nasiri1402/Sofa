//
//  OnboardingLetsBeginPage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingLetsBeginPage: View {

    // MARK: - Public Properties

    let onFinish: () -> Void

    // MARK: - Private Properties

    @State private var phase: Phase = .one

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            WordRevealText(
                text: phase.text,
                font: .system(size: 34.fitW, weight: .bold),
                revealedColor: .white,
                hiddenColor: .white.opacity(0),
                onRevealFinished: advanceToNextPhase
            )
            .padding(.top, 256.fitH)

            Spacer()
        }
        .padding(.horizontal, 16.fitW)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            phase = .one
        }
    }

}

// MARK: - Types

extension OnboardingLetsBeginPage {
    enum Phase: Int, CaseIterable {
        case one, two, three, four, five

        var text: String {
            switch self {
            case .one:
                return [
                    String(localized: "comeUpWithIt"),
                    String(localized: "generateIt"),
                    String(localized: "takeAction")
                ].joined(separator: "\n")
            case .two:
                return String(localized: "journeyBeginsHereAndNow")
            case .three:
                return String(localized: "iWillTurnYourGoalIntoActionPlan")
            case .four:
                return [
                    String(localized: "hello") + " 👋",
                    String(localized: "myNameIsSofa")
                ].joined(separator: "\n")
            case .five:
                return String(localized: "iCanCreateAIGeneratedStepByStepPlanToImplementYourIdea")
            }
        }
    }
}

// MARK: - Private Helpers

private extension OnboardingLetsBeginPage {

    @MainActor
    func advanceToNextPhase() {
        guard let next = nextPhase(after: phase) else {
            onFinish()
            return
        }
        phase = next
    }

    func nextPhase(after phase: Phase) -> Phase? {
        guard let index = Phase.allCases.firstIndex(of: phase),
              Phase.allCases.indices.contains(index + 1) else {
            return nil
        }

        return Phase.allCases[index + 1]
    }
}
