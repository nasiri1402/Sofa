//
//  ServiceLayer.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

enum ServiceLayer {

    // MARK: - Public Properties

    static let analyticsManager = AnalyticsManager()
    static let storeManager: StoreManager = DefaultStoreManager()
    static let networkMonitor: NetworkMonitor = DefaultNetworkMonitor()
    static let dataStorage: DataStorage = DefaultDataStorage()
}
