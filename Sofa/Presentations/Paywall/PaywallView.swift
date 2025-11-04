//
//  PaywallView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct PaywallView: View {

    // MARK: - Public Properties

    @State var viewModel: PaywallViewModel

    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        VStack(alignment: .center, spacing: 24.fitW) {
//            Image(.paywallLamp)
//                .resizable()
//                .frame(width: 115.fitW, height: 150.fitW)
//                .padding(.bottom, -5.fitW)

            Spacer(minLength: .zero)

            TextTitle()
            FeaturesView()

            VStack(spacing: 10.fitW) {
                ForEach(viewModel.subscriptions, id: \.id) { subscription in
                    SubscriptionButton(subscription)
                }
            }
            VStack(spacing: 10.fitW) {
                ContinueButton()
                CancelAnytimeView()
            }
            HStack(spacing: .zero) {
                PrivacyButton(title: String(localized: "termsOfUse"), onTap: viewModel.didTapTermsButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "privacyPolicy"), onTap: viewModel.didTapPrivacyButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "restore"), onTap: viewModel.didTapRestoreButton)
            }
        }
        .background(.black090909)
        .padding(.top, 20.fitW)
        .padding([.bottom, .horizontal], 16.fitW)
        .overlay(alignment: .topLeading) {
            CloseButton()
                .padding(.top, 10.fitW)
                .padding(.leading, 16.fitW)
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

extension PaywallView {
    private func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(.crossCircle)
                .resizable()
                .frame(width: 38.fitW, height: 38.fitW)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func TextTitle() -> some View {
        Text(String(localized: "getYourPersonalizedAIRoadmapIn1Tap"))
            .multilineMinimumScale(lineLimit: 2)
            .multilineTextAlignment(.center)
            .font(.system(size: 22.fitW, weight: .bold))
            .foregroundStyle(.white)
    }

    private func FeaturesView() -> some View {
        HStack(spacing: 10.fitW) {
            Image(._infinity)
                .resizable()
                .frame(width: 28.fitW, height: 28.fitW)

            Text(String(localized: "unlimitedAIPlanGenerationsAndAccessToAllFeatures"))
                .multilineMinimumScale(lineLimit: 2)
                .font(.system(size: 15.fitW))
                .foregroundColor(.grayD1D1D6)
                .multilineTextAlignment(.leading)
        }
    }

    private func SubscriptionButton(_ subscription: PaywallModel.Subscription) -> some View {
        Button {
            viewModel.didTapSubscriptionButton(subscription)
        } label: {
            let isSelected = viewModel.selectedSubscription == subscription
            HStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: 2.fitW) {
                    Text(subscription.title + ", " + viewModel.formatPrice(for: subscription))
                        .font(.system(size: 15.fitW, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(height: 20.fitW)

                    Text(viewModel.formatPriceDescription(for: subscription))
                        .font(.system(size: 11.fitW))
                        .foregroundStyle(.gray8E8E93)
                        .frame(height: 13.fitW)
                }
                Spacer(minLength: 12.fitW)

                if subscription.isBestValue {
                    BestValueBanner()
                        .padding(.trailing, 12.fitW)
                }
                RadioButton(isSelected: isSelected)
            }
            .frame(height: 35.fitW)
            .padding(20.fitW)
            .background(.gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .overlay {
                RoundedRectangle(cornerRadius: 16.fitW)
                    .strokeBorder(.blue007AFF, lineWidth: 2.fitW)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func RadioButton(isSelected: Bool) -> some View {
        Image(isSelected ? .checkboxCircleSelectedWhite : .checkboxCircleUnselected)
            .resizable()
            .frame(width: 24.fitW, height: 24.fitW)
            .animation(.easeInOut, value: isSelected)
    }

    private func BestValueBanner() -> some View {
        Text(String(localized: "bestValue"))
            .font(.system(size: 14.fitW, weight: .medium))
            .foregroundStyle(.black)
            .frame(height: 18.fitW)
            .padding(.horizontal, 10.fitW)
            .padding(.vertical, 6.fitW)
            .background(.green34C759)
            .clipShape(.rect(cornerRadius: 8.fitW))
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

    private func ContinueButton() -> some View {
        let trialSubtitle = String(localized: "then")
        + " "
        + viewModel.formatPrice(for: viewModel.selectedSubscription)
        + "/"
        + viewModel.getUnit(for: viewModel.selectedSubscription).lowercased()

        return PrimaryButton(
            title: viewModel.selectedSubscription.withTrial
            ? String(localized: "try3DaysFree")
            : String(localized: "unlockUnlimitedAIGenerations"),
            subtitle: viewModel.selectedSubscription.withTrial ? trialSubtitle : nil,
            onTap: viewModel.didTapContinueButton
        )
        .animation(.easeInOut, value: viewModel.selectedSubscription)
    }
}
