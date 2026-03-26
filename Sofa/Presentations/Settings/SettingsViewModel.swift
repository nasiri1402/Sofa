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

    var fields: [SettingsModel.Field] {
        if storeManager.hasPurchasedProduct() {
            SettingsModel.Field.allCases.filter { $0 != .pro }
        } else {
            SettingsModel.Field.allCases
        }
    }
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

    private let router: SettingsRouter
    private let storeManager: StoreManager
    private let permissionManager: PermissionManager
    private let notificationManager: NotificationManager

    private let locale: Locale = .current
    private var isNotificationPermissionUpdating = false

    @ObservationIgnored @AppStorage(SofaConstants.AppStorage.isNotificationsEnabled)
    private var isNotificationsEnabled = false

    // MARK: - Inits

    init(
        router: SettingsRouter,
        storeManager: StoreManager,
        permissionManager: PermissionManager,
        notificationManager: NotificationManager
    ) {
        self.router = router
        self.storeManager = storeManager
        self.permissionManager = permissionManager
        self.notificationManager = notificationManager
    }
}

// MARK: - Public Methods

extension SettingsViewModel {

    // MARK: - Input

    func didViewAppear() {
        requestNotificationPermission()
    }

    func didBecomeActive() {
        requestNotificationPermission()
    }

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
            router.route(to: .myData)
        case .language:
            settingsTrigger = UUID()
        case .notifications: break
        }
    }

    func didToggleField(_ field: SettingsModel.Field, isOn: Bool) {
        switch field {
        case .notifications:
            guard !isNotificationPermissionUpdating else { return }
            guard isOn else {
                alertItem = .settings(
                    title: String(localized: "alertConfirmNotificationDisableTitle"),
                    message: String(localized: "alertConfirmNotificationDisableMessage")
                )
                return
            }
            isNotificationPermissionUpdating = true
            permissionManager.requestNotification { [weak self] isGranted in
                guard let self else { return }
                isNotificationsEnabled = isGranted
                if isGranted {
                    notificationManager.rescheduleInactiveNotifications()
                } else {
                    notificationManager.cancelInactiveNotifications()
                    alertItem = .settings(
                        title: String(localized: "alertNotificationAccessTitle"),
                        message: String(localized: "alertNotificationAccessMessage")
                    )
                }
                isNotificationPermissionUpdating = false
            }
        default: break
        }
    }
}

// MARK: - Private Methods

extension SettingsViewModel {
    private func requestNotificationPermission() {
        permissionManager.requestNotification { [weak self] isGranted in
            guard let self else { return }
            isNotificationsEnabled = isGranted
            if isGranted {
                notificationManager.rescheduleInactiveNotifications()
            } else {
                notificationManager.cancelInactiveNotifications()
            }
        }
    }
}
