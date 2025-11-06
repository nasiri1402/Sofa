//
//  OnboardingRateUsPage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import Lottie
import SwiftUI

struct OnboardingRateUsPage: View {

    // MARK: - Public Properties

    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            LottieView(animation: .named("reviewing"))
                .looping()
                .resizable()
                .frame(width: 150.fitW, height: 150.fitW)

            Text(String(localized: "pleaseRateUs"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 16.fitW)
                .multilineTextAlignment(.center)

            Text(String(localized: "pleaseRateUsDescription"))
                .font(.system(size: 17.fitW))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer(minLength: .zero)
        }
        .frame(maxWidth: .infinity)
        .transition(.blurReplace.combined(with: .opacity))
        .padding(.top, 170.fitW)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .onAppear {
            isPreviousEnabled = true
            isNextEnabled = true
        }
    }
}
