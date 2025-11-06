//
//  OnboardingLogoPage.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import SwiftUI

struct OnboardingLogoPage: View {

    // MARK: - Public Properties

    let onFinish: () -> Void

    // MARK: - Private Properties

    @State private var isTextHidden = true

    // MARK: - Body

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack(alignment: .leading, spacing: .zero) {
                Image(.onboardingLogo)
                    .resizable()
                    .frame(width: 185.fitW, height: 80.fitW)

                if !isTextHidden {
                    Text(String(localized: "aiPlanGenerator"))
                        .font(.system(size: 20.fitW))
                        .foregroundStyle(.white)
                        .frame(height: 25.fitW)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.6), value: isTextHidden)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isTextHidden = false
                } completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        onFinish()
                    }
                }
            }
        }
    }
}
