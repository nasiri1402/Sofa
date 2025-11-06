//
//  MailView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import MessageUI
import SwiftUI

struct MailView {

    // MARK: - Public Properties

    let recipients: [String]
    let subject: String
    let messageBody: String

    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss
}

// MARK: - UIViewControllerRepresentable

extension MailView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(messageBody, isHTML: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator

extension MailView {
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        // MARK: - Public Properties

        var parent: MailView

        // MARK: - Initializers

        init(_ parent: MailView) {
            self.parent = parent
        }

        // MARK: - Public Methods

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                parent.dismiss()
            }
        }
    }
}
