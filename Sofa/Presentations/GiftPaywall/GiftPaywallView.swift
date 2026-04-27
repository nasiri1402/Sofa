//
//  GiftPaywallView.swift
//  Sofa
//
//  Created by dukes on 4/17/26.
//

import SwiftUI

struct GiftPaywallView: View {

    // MARK: - Public Properties

    @State var viewModel: GiftPaywallViewModel

    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16.fitW) {
            Spacer(minLength: .zero)

            switch viewModel.state {
            case .teaser: TeaserState()
            case .offer: OfferState()
            }
            VStack(spacing: 10.fitH) {
                PrimaryButton(
                    title: viewModel.state.action,
                    onTap: viewModel.didTapContinueButton
                )
                CancelAnytimeView()
                    .opacity(viewModel.state == .offer ? 1 : 0)
            }
            .padding(.horizontal, 16.fitW)

            HStack(spacing: .zero) {
                PrivacyButton(title: String(localized: "terms"), onTap: viewModel.didTapTermsButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "privacy"), onTap: viewModel.didTapPrivacyButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "restore"), onTap: viewModel.didTapRestoreButton)
            }
            .opacity(viewModel.state == .offer ? 1 : 0)
            .padding(.horizontal, 16.fitW)
        }
        .animation(.easeInOut, value: viewModel.state)
        .padding(.top, 20.fitH)
        .padding(.bottom, 8.fitH)
        .background(.black090909)
        .overlay(alignment: .topLeading) {
            if viewModel.state == .offer {
                CloseButton()
                    .padding(.horizontal, 16.fitW)
                    .transition(.opacity)
            }
        }
        .overlay {
            ActivityIndicator(isLoading: viewModel.isLoading)
        }
        .sheet(isPresented: $viewModel.isSafariPresented) {
            if let url = viewModel.safariURL {
                SafariView(url: url)
            }
        }
        .alert(item: $viewModel.alertItem) {
            $0.alert()
        }
        .onChange(of: viewModel.dismissTrigger) { _, _ in
            dismiss()
        }
    }
}

// MARK: - Subviews

extension GiftPaywallView {
    private func TeaserState() -> some View {
        VStack(spacing: .zero) {
            ZStack {
                Circle()
                    .fill(.blue007AFF)
                    .frame(width: 180.fitW, height: 180.fitW)
                    .blur(radius: 50.fitW)

                Image(.giftPaywallBox)
                    .resizable()
                    .frame(width: 256.fitW, height: 256.fitW)
            }
            .padding(.bottom, 40.fitH)

            Text(viewModel.state.subtitle)
                .multilineMinimumScale()
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.bottom, 32.fitH)

            Text(viewModel.state.title)
                .multilineMinimumScale(lineLimit: 3)
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16.fitW)
        .padding(.bottom, 16.fitH)
        .transition(.opacity)
    }

    private func OfferState() -> some View {
        VStack(alignment: .leading, spacing: 32.fitH) {
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.state.title)
                    .multilineMinimumScale(lineLimit: 2)
                    .font(.system(size: 76.fitW, weight: .black))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(-20.fitH)

                Text(viewModel.formatOfferDiscount())
                    .multilineMinimumScale()
                    .font(.system(size: 76.fitW, weight: .black))
                    .foregroundStyle(.blue007AFF)
            }

            Text(viewModel.state.subtitle)
                .multilineMinimumScale(lineLimit: 2)
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .lineSpacing(-12.fitH)

            PriceHighlight()
        }
        .padding(.horizontal, 16.fitW)
        .padding(.bottom, 16.fitH)
        .transition(.opacity)
    }

    private func CloseButton() -> some View {
        Button(action: viewModel.didTapCloseButton) {
            Image(.crossCircle)
                .resizable()
                .frame(width: 38.fitW, height: 38.fitW)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func PriceHighlight() -> some View {
        HStack(alignment: .center, spacing: 16.fitH) {
            Image(.giftPaywallWreathLeft)
                .resizable()
                .scaledToFit()
                .frame(width: 50.fitW, height: 100.fitH)

            VStack(spacing: .zero) {
                Text(viewModel.formatGiftPrice())
                    .multilineMinimumScale()
                    .font(.system(size: 20.fitW, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(height: 25.fitH)
                    .padding(.bottom, 2.fitH)

                Text(viewModel.formatStandardPrice())
                    .multilineMinimumScale()
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.gray8E8E93)
                    .frame(height: 20.fitH)

                Text(viewModel.formatDiscountBadge())
                    .multilineMinimumScale()
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10.fitW)
                    .frame(height: 32.fitH)
                    .background(.green34C759)
                    .clipShape(.rect(cornerRadius: 8.fitW))
                    .padding(.top, 10.fitH)
            }
            .frame(maxWidth: .infinity)

            Image(.giftPaywallWreathRight)
                .resizable()
                .scaledToFit()
                .frame(width: 50.fitW, height: 100.fitH)
        }
        .padding(.horizontal, 6.fitW)
    }

    private func CancelAnytimeView() -> some View {
        HStack(spacing: 4.fitW) {
            Image(.shieldCheck)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(String(localized: "appStoreProtected") + ". " + String(localized: "cancelAnyTime"))
                .multilineMinimumScale()
                .font(.system(size: 12.fitW))
                .foregroundStyle(.grayD1D1D6)
        }
        .frame(maxWidth: .infinity)
    }

    private func PrivacyButton(title: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Text(title)
                .multilineMinimumScale()
                .font(.system(size: 12.fitW, weight: .medium))
                .foregroundStyle(.gray8E8E93)
                .frame(height: 16.fitW)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }
}
