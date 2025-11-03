//
//  TabBarViewModel.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class TabBarViewModel {

    // MARK: - Public Properties
    
    var selectedTab: TabBarModel.Tab = .generator
}
