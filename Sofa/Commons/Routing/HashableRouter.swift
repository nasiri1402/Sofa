//
//  HashableRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation

class HashableRouter {

    // MARK: - Private Properties

    private let id = UUID()
}

// MARK: - Hashable

extension HashableRouter: Hashable {
    static func == (lhs: HashableRouter, rhs: HashableRouter) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
