//
//  Text+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

extension Text {
    func multilineMinimumScale(_ scaleFactor: CGFloat = 0.4, lineLimit: Int = 1) -> some View {
        self
            .lineLimit(lineLimit)
            .minimumScaleFactor(scaleFactor)
    }
}
