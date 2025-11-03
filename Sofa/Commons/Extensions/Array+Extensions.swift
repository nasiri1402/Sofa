//
//  Array+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
