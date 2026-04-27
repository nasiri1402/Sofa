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
        VStack(alignment: .center, spacing: 16.fitH) {
            Spacer(minLength: .zero)
            ReviewsCarouselView()

            FeaturesView()
                .padding(.horizontal, 16.fitW)

            TrialView()
                .padding(.horizontal, 16.fitW)

            VStack(spacing: 10.fitH) {
                ForEach(viewModel.subscriptions, id: \.id) { subscription in
                    SubscriptionButton(subscription)
                }
            }
            .padding(.horizontal, 16.fitW)

            VStack(spacing: 10.fitH) {
                ContinueButton()
                CancelAnytimeView()
            }
            .padding(.horizontal, 16.fitW)

            HStack(spacing: .zero) {
                PrivacyButton(title: String(localized: "terms"), onTap: viewModel.didTapTermsButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "privacy"), onTap: viewModel.didTapPrivacyButton)
                Spacer(minLength: 6.fitW)
                PrivacyButton(title: String(localized: "restore"), onTap: viewModel.didTapRestoreButton)
            }
            .padding(.horizontal, 16.fitW)
        }
        .padding(.top, 20.fitH)
        .padding(.bottom, 8.fitH)
        .background(.black090909)
        .overlay(alignment: .topLeading) {
            HStack(spacing: 16.fitW) {
                CloseButton()
                TextTitle()
                CloseButton()
                    .hidden()
            }
            .padding(.horizontal, 16.fitW)
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
        HStack(alignment: .center, spacing: 10.fitW) {
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

    private func ReviewsCarouselView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10.fitW) {
                let images: [ImageResource] = [.paywallReview1, .paywallReview2, .paywallReview3]
                let width = UIScreen.main.bounds.width - 2 * 38.fitW

                ForEach(images, id: \.self) { image in
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 38.fitW, for: .scrollContent)
    }

    private func TrialView() -> some View {
        HStack(spacing: .zero) {
            Text(String(localized: "notSureYetEnableFreeTrial"))
                .multilineMinimumScale()
                .foregroundStyle(viewModel.isTrialOn ? .white : .gray8E8E93)
                .font(.system(size: 13.fitW))
                .animation(.easeInOut, value: viewModel.isTrialOn)

            Spacer(minLength: 8.fitW)

            Toggle(String(""), isOn: $viewModel.isTrialOn)
                .toggleStyle(.switch)
                .tint(.blue007AFF)
                .scaleEffect(0.93)
                .fixedSize(horizontal: true, vertical: false)
                .hapticFeedback()
        }
        .padding(.horizontal, 20.fitW)
        .frame(height: 51.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 16.fitW))
        .contentShape(.rect)
    }

    private func SubscriptionButton(_ subscription: PaywallModel.Subscription) -> some View {
        Button {
            viewModel.didTapSubscriptionButton(subscription)
        } label: {
            let isSelected = viewModel.selectedSubscription == subscription
            HStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: 2.fitW) {
                    Text(subscription.title + " - " + viewModel.formatPrice(for: subscription))
                        .multilineMinimumScale()
                        .font(.system(size: 15.fitW, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : .gray8E8E93)
                        .frame(height: 20.fitW)

                    Text(viewModel.formatPriceDescription(for: subscription))
                        .multilineMinimumScale()
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
        .animation(.easeInOut, value: viewModel.selectedSubscription)
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
