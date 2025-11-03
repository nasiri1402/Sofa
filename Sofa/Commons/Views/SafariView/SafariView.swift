//
//  SafariView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SafariServices
import SwiftUI

struct SafariView {

    // MARK: - Public Properties

    let url: URL
}

// MARK: - UIViewControllerRepresentable

extension SafariView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.dismissButtonStyle = .close
        return controller
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {}
}
