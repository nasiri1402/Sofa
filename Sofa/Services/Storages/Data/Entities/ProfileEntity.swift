//
//  ProfileEntity.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftData

@Model
final class ProfileEntity {
    @Attribute(.unique) var id: UUID

    init(from model: Profile) {
        self.id = model.id
    }

    func toProfile() -> Profile {
        Profile(
            id: id
        )
    }
}
