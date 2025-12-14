//
//  GenerationLoaderView.swift
//  Sofa
//
//  Created by dukes on 11/12/25.
//

import Lottie
import SwiftUI

struct GenerationLoaderView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: GenerationLoaderViewModel

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            Color.black090909
                .ignoresSafeArea()

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
                    text: viewModel.message.description,
                    font: .system(size: 17.fitW),
                    revealedColor: .white.opacity(0.4),
                    pauseAfterReveal: 3,
                    onFinished: viewModel.didFinishReveal
                )
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: .zero)
            }
            .padding(.top, 170.fitW)
            .padding(.horizontal, 16.fitW)
            .frame(maxWidth: .infinity)
            .transition(.blurReplace.combined(with: .opacity))
        }
        .navigationBarBackButtonHidden()
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .sensoryFeedback(.success, trigger: viewModel.feedbackTrigger)
    }
}
