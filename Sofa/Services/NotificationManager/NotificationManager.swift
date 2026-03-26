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

    private let inactiveContent: [(title: String, message: String)] = [
        ("Your idea is waiting", "Come back to Sofa and continue building your plan."),
        ("Small step today?", "Open Sofa and move your project one step forward."),
        ("Stay on track", "Your next milestone is closer than you think."),
        ("Quick progress check", "Take 2 minutes in Sofa and keep momentum."),
        ("Your project misses you", "Return to Sofa and pick up where you left off."),
        ("Back to your roadmap", "Your plan is ready for the next update."),
        ("Keep building", "Consistency beats intensity. Continue in Sofa."),
        ("One more action", "Open Sofa and complete the next tiny task."),
        ("Progress reminder", "You are closer than yesterday. Keep going."),
        ("Time to execute", "Review your steps in Sofa and take action today."),
        ("Ready for round two?", "Jump back into Sofa and refine your plan."),
        ("Momentum check", "A short session in Sofa can move things ahead."),
        ("Your plan is still there", "Continue your project in Sofa anytime."),
        ("Build with clarity", "Reopen Sofa and align your next priorities."),
        ("Final reminder", "Return to Sofa and keep your project alive.")
    ]

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
