//
//  PermissionManager.swift
//  Sofa
//
//  Created by dukes on 3/26/26.
//

import UserNotifications

// MARK: - Interfaces

protocol PermissionManager {
    func requestNotification(completion: @escaping (Bool) -> Void)
}

// MARK: - Implementations

final class DefaultPermissionManager: PermissionManager {

    // MARK: - Private Properties

    private let notificationCenter: UNUserNotificationCenter = .current()

    // MARK: - Public Methods

    func requestNotification(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                completion(isGranted)
            }
        }
    }
}
