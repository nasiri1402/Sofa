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
        ZStack(alignment: .topLeading) {
            Color.black090909
                .ignoresSafeArea()

            switch viewModel.state {
            case .teaser: TeaserState()
            case .offer: OfferState()
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
            Image(.giftPaywallBox)
                .resizable()
                .scaledToFit()
                .frame(width: 256.fitW, height: 256.fitW)
                .padding(.top, 56.fitW)
                .padding(.bottom, 40.fitW)

            Text(viewModel.state.subtitle)
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.bottom, 32.fitW)

            Text(viewModel.state.title)
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)

            Spacer(minLength: 16.fitW)

            PrimaryButton(
                title: viewModel.state.action,
                onTap: viewModel.didTapContinueButton
            )
            .padding(.bottom, 82.fitW)
        }
        .padding(.horizontal, 16.fitW)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func OfferState() -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            CloseButton()

            Text(viewModel.state.title)
                .font(.system(size: 76.fitW, weight: .black))
                .foregroundStyle(.white.opacity(0.95))
                .lineSpacing(-10.fitW)

            Text(viewModel.formatOfferDiscount())
                .font(.system(size: 76.fitW, weight: .black))
                .foregroundStyle(.blue007AFF)
                .padding(.bottom, 36.fitW)

            Text(viewModel.state.subtitle)
                .font(.system(size: 46.fitW, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .lineSpacing(-8.fitW)
                .padding(.bottom, 36.fitW)

            PriceHighlight()

            Spacer(minLength: .zero)

            VStack(spacing: 10.fitW) {
                PrimaryButton(
                    title: viewModel.state.action,
                    onTap: viewModel.didTapContinueButton
                )
                CancelAnytimeView()

                HStack(spacing: .zero) {
                    PrivacyButton(title: String(localized: "terms"), onTap: viewModel.didTapTermsButton)
                    Spacer(minLength: 6.fitW)
                    PrivacyButton(title: String(localized: "privacy"), onTap: viewModel.didTapPrivacyButton)
                    Spacer(minLength: 6.fitW)
                    PrivacyButton(title: String(localized: "restore"), onTap: viewModel.didTapRestoreButton)
                }
            }
        }
        .padding(.top, 20.fitW)
        .padding([.horizontal, .bottom], 16.fitW)
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
        HStack(alignment: .center, spacing: 16.fitW) {
            Image(.giftPaywallWreathLeft)
                .resizable()
                .scaledToFit()
                .frame(width: 50.fitW, height: 100.fitW)

            VStack(spacing: .zero) {
                Text(viewModel.formatGiftPrice())
                    .font(.system(size: 20.fitW, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(height: 25.fitW)
                    .padding(.bottom, 2.fitW)

                Text(viewModel.formatStandardPrice())
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.gray8E8E93)
                    .frame(height: 20.fitW)

                Text(viewModel.formatDiscountBadge())
                    .font(.system(size: 16.fitW, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14.fitW)
                    .frame(height: 38.fitW)
                    .background(.green34C759)
                    .clipShape(.rect(cornerRadius: 10.fitW))
                    .padding(.top, 16.fitW)
            }
            .frame(maxWidth: .infinity)

            Image(.giftPaywallWreathRight)
                .resizable()
                .scaledToFit()
                .frame(width: 50.fitW, height: 100.fitW)
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
