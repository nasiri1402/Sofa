//
//  Pasteboard.swift
//  Sofa
//
//  Created by dukes on 6/3/26.
//

import Foundation
import UIKit

// MARK: - Interfaces

protocol Pasteboard {
    func copy(_ text: String)
}

// MARK: - Implementations

final class DefaultPasteboard: Pasteboard {

    // MARK: - Private Properties

    private let pasteboard: UIPasteboard = .general

    // MARK: - Public Methods

    func copy(_ text: String) {
        pasteboard.string = text
    }
}
