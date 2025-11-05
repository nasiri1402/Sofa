//
//  RateUsView.swift
//  Sofa
//
//  Created by dukes on 11/5/25.
//

import Lottie
import StoreKit
import SwiftUI

struct RateUsView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: RateUsViewModel

    // MARK: - Private Properties

    @Environment(\.requestReview) private var requestReview

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    BackButton()
                    Spacer()
                }
                .padding(.top, 10.fitW)
                .padding(.leading, 16.fitW)

                VStack(alignment: .leading, spacing: .zero) {
                    RateStateView()
                        .padding(.top, 154.fitW)

                    Spacer(minLength: .zero)
                    RateButton()
                        .padding(.bottom, 31.fitW)
                }
                .padding(16.fitW)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .overlay {
            ActivityIndicator(isLoading: viewModel.isLoading)
        }
    }

    // MARK: - Views

    private func BackButton() -> some View {
        Button(action: viewModel.didTapBackButton) {
            Image(.backCircle)
                .resizable()
                .frame(width: 46.fitW, height: 46.fitW)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func RateStateView() -> some View {
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
        }
        .frame(maxWidth: .infinity)
        .transition(.blurReplace.combined(with: .opacity))
    }

    private func RateButton() -> some View {
        PrimaryButton(title: String(localized: "rateUs")) {
            viewModel.didTapRateButton()
            requestReview()
        }
    }
}
