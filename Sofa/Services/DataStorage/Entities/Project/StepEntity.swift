//
//  StepEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

@Model
final class StepEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var title: String
    var number: Int
    var isCompleted: Bool

    // MARK: - Inits

    init(from model: Project.Plan.Step) {
        self.id = model.id
        self.title = model.title
        self.number = model.number
        self.isCompleted = model.isCompleted
    }

    // MARK: - Public Methods

    func toStep() -> Project.Plan.Step {
        Project.Plan.Step(
            id: id,
            title: title,
            number: number,
            isCompleted: isCompleted
        )
    }
}
