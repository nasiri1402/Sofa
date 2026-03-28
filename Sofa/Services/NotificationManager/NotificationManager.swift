//
//  NotificationManager.swift
//  Sofa
//
//  Created by Codex on 3/26/26.
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

    private var inactiveContent: [(title: String, message: String)] {
        (1...15).map { index in
            (
                String(localized: "inactiveUserNotificationTitle\(index)"),
                String(localized: "inactiveUserNotificationMessage\(index)")
            )
        }
    }

    // MARK: - Public Methods

    func rescheduleInactiveNotifications() {
        let ids = makeInactiveNotificationIDs()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        guard isNotificationsEnabled else { return }
        scheduleInactiveQueue(from: .now)
    }

    func cancelInactiveNotifications() {
        let ids = makeInactiveNotificationIDs()
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
        inactiveContent.enumerated().compactMap { index, item in
            let dayOffset = index + 1
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
            content.title = item.title
            content.body = item.message
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return UNNotificationRequest(
                identifier: inactiveNotificationID(for: index),
                content: content,
                trigger: trigger
            )
        }
    }

    private func makeInactiveNotificationIDs() -> [String] {
        inactiveContent.indices.map(inactiveNotificationID(for:))
    }

    private func inactiveNotificationID(for index: Int) -> String {
        "inactive_user_notification_\(index)"
    }
}
