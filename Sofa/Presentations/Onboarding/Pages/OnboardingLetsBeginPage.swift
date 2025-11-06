//
//  OnboardingLetsBeginPage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingLetsBeginPage: View {

    // MARK: - Public Properties

    @Binding var isNextEnabled: Bool

    // MARK: - Private Properties

    @State private var phase: Phase = .one

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            WordRevealText(
                text: phase.text,
                font: .system(size: 34.fitW, weight: .bold),
                onFinished: advanceToNextPhase
            )
            .padding(.top, 256.fitH)

            Spacer()
        }
        .padding(.horizontal, 16.fitW)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Private Methods

    @MainActor
    func advanceToNextPhase() {
        guard let next = nextPhase(after: phase) else {
            isNextEnabled = true
            return
        }
        phase = next
    }

    func nextPhase(after phase: Phase) -> Phase? {
        guard let index = Phase.allCases.firstIndex(of: phase) else { return nil }
        return Phase.allCases[safe: index + 1]
    }
}

// MARK: - Types

extension OnboardingLetsBeginPage {
    enum Phase: Int, CaseIterable {
        case one, two, three, four, five

        var text: String {
            switch self {
            case .one: [
                String(localized: "comeUpWithIt"),
                String(localized: "generateIt"),
                String(localized: "takeAction")
            ].joined(separator: "\n")
            case .two: String(localized: "journeyBeginsHereAndNow")
            case .three: String(localized: "iWillTurnYourGoalIntoActionPlan")
            case .four: [
                String(localized: "hello") + " 👋",
                String(localized: "myNameIsSofa")
            ].joined(separator: "\n")
            case .five: String(localized: "iCanCreateAIGeneratedStepByStepPlanToImplementYourIdea")
            }
        }
    }
}
