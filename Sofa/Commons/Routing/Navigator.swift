//
//  Navigator.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation

protocol Navigator {
    @MainActor
    func push(_ router: any Routable)

    @MainActor
    func pop()
    
    @MainActor
    func popToRoot()
}
