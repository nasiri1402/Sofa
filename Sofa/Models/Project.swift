//
//  Project.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation

struct Project: Identifiable {
    let id: UUID
    let title: String
    let summary: String
    let emoji: String
    let createdAt: Date
    var updatedAt: Date
}
