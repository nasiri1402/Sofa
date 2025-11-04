//
//  SettingsView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: SettingsViewModel

    // MARK: - Private Properties

    @Environment(\.openURL) private var openURL

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 10.fitW) {
                    ForEach(viewModel.fields, id: \.self) { field in
                        FieldButton(field)
                            .padding(.bottom, field.needsExtraBottomPadding ? 14.fitW : .zero)
                    }
                    VersionText()
                        .padding(.top, 14.fitW)
                }
                .padding(.horizontal, 16.fitW)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .contentMargins(.vertical, 24.fitW, for: .scrollContent)
        }
        .navigationTitle(String(localized: "settings"))
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $viewModel.isPaywallPresented) {
            PaywallCover()
        }
        .sheet(isPresented: $viewModel.isSafariPresented) {
            if let url = viewModel.safariURL {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $viewModel.isMailComposerPresented) {
            MailView(
                recipients: [viewModel.supportMessage.email],
                subject: viewModel.supportMessage.title,
                messageBody: viewModel.supportMessage.message
            )
        }
        .sheet(isPresented: $viewModel.isSharePresented) {
            ShareView(items: [SofaConstants.AppStore.appLink], onShared: nil)
                .presentationDetents([.medium, .large])
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
        .onChange(of: viewModel.settingsTrigger) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                openURL(url)
            }
        }
        .onChange(of: viewModel.reviewTrigger) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if let url = URL(string: SofaConstants.AppStore.appLink), UIApplication.shared.canOpenURL(url) {
                openURL(url)
            }
        }
    }

    // MARK: - Views

    private func FieldButton(_ field: SettingsModel.Field) -> some View {
        Button {
            viewModel.didTapFieldButton(field)
        } label: {
            HStack(spacing: 6.fitW) {
                Image(field.icon)
                    .resizable()
                    .frame(width: 24.fitW, height: 24.fitW)

                Text(field.title)
                    .font(.system(size: 16.fitW, weight: .semibold))
                    .foregroundStyle(Color(field.foregroundColor))

                Spacer(minLength: .zero)

                if field == .language, let language = Locale.currentLanguageName {
                    Text(language)
                        .font(.system(size: 16.fitW))
                        .foregroundStyle(.gray8E8E93)
                }
            }
            .padding(20.fitW)
            .background(field == .pro ? .yellowFFCC00 : .gray787880.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16.fitW))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func VersionText() -> some View {
        Text(String(
            format: String(localized: "appVersionFormat"),
            SofaConstants.AppInfo.shortVersion
        ).replacingOccurrences(of: ":", with: ""))
        .font(.system(size: 17.fitW))
        .foregroundStyle(.white.opacity(0.4))
    }

    private func PaywallCover() -> some View {
        PaywallView(viewModel: PaywallViewModel(
            storeManager: ServiceLayer.storeManager,
            networkMonitor: ServiceLayer.networkMonitor,
            analyticsManager: ServiceLayer.analyticsManager,
            placement: .settings
        ))
    }
}
