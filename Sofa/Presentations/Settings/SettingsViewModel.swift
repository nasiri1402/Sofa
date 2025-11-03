//
//  SettingsViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import MessageUI
import Observation
import SwiftUI

@MainActor @Observable
final class SettingsViewModel {

    // MARK: - Public Properties

    let allFields = SettingsModel.Field.allCases
    let supportMessage = SettingsModel.SupportMail(
        email: SofaConstants.AppSupport.email,
        title: String(localized: "supportRequestTitle"),
        message: [
            "\n\n",
            String(format: String(localized: "deviceModelFormat"), SofaConstants.AppInfo.deviceModel),
            String(format: String(localized: "deviceSystemVersionFormat"), SofaConstants.AppInfo.deviceSystem),
            String(format: String(localized: "appVersionFormat"), SofaConstants.AppInfo.fullVersion)
        ].joined(separator: "\n")
    )
    private(set) var reviewTrigger = UUID()
    private(set) var settingsTrigger = UUID()
    private(set) var safariURL: URL?
    var alertItem: AlertItem?
    var isSafariPresented = false
    var isMailComposerPresented = false
    var isSharePresented = false
    var isPaywallPresented = false

    // MARK: - Private Properties

    private let storeManager: StoreManager

    private let locale: Locale = .current

    // MARK: - Inits

    init(storeManager: StoreManager) {
        self.storeManager = storeManager
    }
}

// MARK: - Public Methods

extension SettingsViewModel {

    // MARK: - Output

    func isSubscribed() -> Bool {
        storeManager.hasPurchasedProduct()
    }

    // MARK: - Input

    func didTapFieldButton(_ field: SettingsModel.Field) {
        switch field {
        case .pro:
            isPaywallPresented = true
        case .termsOfUse:
            safariURL = URL(string: SofaConstants.AppSupport.terms)
            isSafariPresented = true
        case .privacyPolicy:
            safariURL = URL(string: SofaConstants.AppSupport.privacy)
            isSafariPresented = true
        case .share:
            isSharePresented = true
        case .contactUs:
            if MFMailComposeViewController.canSendMail() {
                isMailComposerPresented = true
            } else {
                alertItem = AlertItem(
                    title: Text(String(localized: "error")),
                    message: Text(
                        String(format: String(localized: "mailComposeUnavailableError"), SofaConstants.AppSupport.email)
                    ),
                    primaryButton: .default(Text(String(localized: "ok"))),
                    secondaryButton: nil
                )
            }
        case .rateUs:
            reviewTrigger = UUID()
        case .myData:
            // TODO: Навигация к моим данным
            break
        case .language:
            settingsTrigger = UUID()
        }
    }
}
