//
//  WeekEntity.swift
//  Sofa
//
//  Created by dukes on 5/17/26.
//

import Foundation
import SwiftData

@Model
final class WeekEntity {

    // MARK: - Public Properties

    @Attribute(.unique)
    var id: UUID
    var number: Int
    @Relationship(deleteRule: .cascade)
    var steps: [StepEntity]

    // MARK: - Inits

    init(from model: Project.Plan.Week) {
        self.id = model.id
        self.number = model.number
        self.steps = model.steps.map { StepEntity(from: $0) }
    }

    // MARK: - Public Methods

    func toWeek() -> Project.Plan.Week {
        Project.Plan.Week(
            id: id,
            number: number,
            steps: steps.map { $0.toStep() }.sorted { $0.number < $1.number }
        )
    }
}
