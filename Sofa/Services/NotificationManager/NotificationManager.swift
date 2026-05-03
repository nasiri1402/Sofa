//
//  NotificationManager.swift
//  Sofa
//
//  Created by dukes on 3/26/26.
//

import SwiftUI
import UserNotifications

// MARK: - Interfaces

protocol NotificationManager {
    func rescheduleInactiveNotifications()
    func cancelInactiveNotifications()
}

// MARK: - Implementations

final class DefaultNotificationManager: NotificationManager {

    // MARK: - Private Properties

    @AppStorage(SofaConstants.AppStorage.isNotificationsEnabled)
    private var isNotificationsEnabled = false

    private let notificationCenter: UNUserNotificationCenter = .current()
    private let calendar: Calendar = .current

    // MARK: - Public Methods

    func rescheduleInactiveNotifications() {
        let ids = UserNotification.Inactive.allCases.map(\.id)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        guard isNotificationsEnabled else { return }
        scheduleInactiveQueue(from: .now)
    }

    func cancelInactiveNotifications() {
        let ids = UserNotification.Inactive.allCases.map(\.id)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Private Methods

    private func scheduleInactiveQueue(from date: Date) {
        let requests = makeInactiveRequests(from: date)
        guard !requests.isEmpty else { return }
        for request in requests {
            notificationCenter.add(request)
        }
    }

    private func makeInactiveRequests(from date: Date) -> [UNNotificationRequest] {
        let notifications = UserNotification.Inactive.allCases
        let notificationContents = notifications.map(\.content).shuffled()
        return notifications.enumerated().compactMap { index, notification in
            let dayOffset = 1 + index
            guard let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: date) else {
                return nil
            }
            var components = calendar.dateComponents([.year, .month, .day], from: targetDay)
            components.hour = 12
            components.minute = .zero
            components.second = .zero
            components.timeZone = .current
            guard let finalDate = calendar.date(from: components), finalDate > date else {
                return nil
            }
            let content = UNMutableNotificationContent()
            let notificationContent = notificationContents[index % notificationContents.count]
            content.title = notificationContent.title
            content.body = notificationContent.message
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        }
    }
}

extension DefaultNotificationManager {

    private enum UserNotification {
        enum Inactive: Int, CaseIterable {
            case first, second, third, fourth, fifth
            case sixth, seventh, eighth, ninth, tenth
            case eleventh, twelfth, thirteenth, fourteenth, fifteenth

            var id: String {
                "inactive_user_notification_" + rawValue.description
            }

            var content: (title: String, message: String) {
                (title, message)
            }

            private var title: String {
                switch self {
                case .first: String(localized: "inactiveUserNotificationTitle1")
                case .second: String(localized: "inactiveUserNotificationTitle2")
                case .third: String(localized: "inactiveUserNotificationTitle3")
                case .fourth: String(localized: "inactiveUserNotificationTitle4")
                case .fifth: String(localized: "inactiveUserNotificationTitle5")
                case .sixth: String(localized: "inactiveUserNotificationTitle6")
                case .seventh: String(localized: "inactiveUserNotificationTitle7")
                case .eighth: String(localized: "inactiveUserNotificationTitle8")
                case .ninth: String(localized: "inactiveUserNotificationTitle9")
                case .tenth: String(localized: "inactiveUserNotificationTitle10")
                case .eleventh: String(localized: "inactiveUserNotificationTitle11")
                case .twelfth: String(localized: "inactiveUserNotificationTitle12")
                case .thirteenth: String(localized: "inactiveUserNotificationTitle13")
                case .fourteenth: String(localized: "inactiveUserNotificationTitle14")
                case .fifteenth: String(localized: "inactiveUserNotificationTitle15")
                }
            }

            private var message: String {
                switch self {
                case .first: String(localized: "inactiveUserNotificationMessage1")
                case .second: String(localized: "inactiveUserNotificationMessage2")
                case .third: String(localized: "inactiveUserNotificationMessage3")
                case .fourth: String(localized: "inactiveUserNotificationMessage4")
                case .fifth: String(localized: "inactiveUserNotificationMessage5")
                case .sixth: String(localized: "inactiveUserNotificationMessage6")
                case .seventh: String(localized: "inactiveUserNotificationMessage7")
                case .eighth: String(localized: "inactiveUserNotificationMessage8")
                case .ninth: String(localized: "inactiveUserNotificationMessage9")
                case .tenth: String(localized: "inactiveUserNotificationMessage10")
                case .eleventh: String(localized: "inactiveUserNotificationMessage11")
                case .twelfth: String(localized: "inactiveUserNotificationMessage12")
                case .thirteenth: String(localized: "inactiveUserNotificationMessage13")
                case .fourteenth: String(localized: "inactiveUserNotificationMessage14")
                case .fifteenth: String(localized: "inactiveUserNotificationMessage15")
                }
            }
        }
    }
}
