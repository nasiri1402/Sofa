//
//  NetworkMonitor.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Network

protocol NetworkMonitor {
    var isConnected: Bool { get }

    func startMonitoring()
    func stopMonitoring()
}

final class DefaultNetworkMonitor: NetworkMonitor {

    // MARK: - Public Properties

    private(set) var isConnected = false

    // MARK: - Private Properties

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(
        label: SofaConstants.AppInfo.bundleName + ".networkMonitor",
        qos: .userInteractive
    )

    // MARK: - Public Methods

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
