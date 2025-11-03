//
//  Int+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

extension Int {

    // MARK: - Public Properties

    var fitW: CGFloat {
        CGFloat(self) * screenSize.width / referenceSize.width
    }

    var fitH: CGFloat {
        CGFloat(self) * screenSize.height / referenceSize.height
    }

    // MARK: - Private Properties

    private var referenceSize: CGSize {
        CGSize(width: 375, height: 812)
    }

    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
}
