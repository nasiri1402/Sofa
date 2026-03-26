//
//  SofaConstants.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import SwiftUI

enum SofaConstants {

    // MARK: - AppInfo

    enum AppInfo {
        static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.ajdar.ai.sofa"
        static let bundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Sofa"
        static let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Sofa"
        static let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        static let buildNumber = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "0"
        static let fullVersion = "v\(shortVersion) (\(buildNumber))"
        static let deviceSystem = [UIDevice.current.systemName, UIDevice.current.systemVersion].joined(separator: " ")
        static let deviceModel = UIDevice.current.model
    }

    // MARK: - AppSupport

    enum AppSupport {
        static let email = "avaitagency@gmail.com"
        static let terms = "https://sofa-app.framer.website/terms-of-use"
        static let privacy = "https://sofa-app.framer.website/privacy"
    }

    // MARK: - AppStorage

    enum AppStorage {
        static let isBeforeLaunched = "isBeforeLaunched"
        static let isProfileCreated = "isProfileCreated"
        static let isNotificationsEnabled = "isNotificationsEnabled"
    }

    // MARK: - AppStore

    enum AppStore {
        static let appID = "6755126023"
        static let appLink = "https://apps.apple.com/app/id\(appID)"
        static var reviewLink = "itms-apps://apps.apple.com/app/id\(appID)?action=write-review"
    }
}
