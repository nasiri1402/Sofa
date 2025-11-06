//
//  ShareView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct ShareView {

    // MARK: - Public Properties

    let items: [Any]
    let onShared: (() -> Void)?
}

// MARK: - UIViewControllerRepresentable

extension ShareView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityVC.completionWithItemsHandler = { _, isShared, _, error in
            guard error == nil, isShared else { return }
            onShared?()
        }
        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
