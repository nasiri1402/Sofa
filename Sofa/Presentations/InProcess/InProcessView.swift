//
//  InProcessView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct InProcessView: View {

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.black090909)
                .ignoresSafeArea(edges: .all)
        }
        .navigationTitle(String(localized: "inProcess"))
        .navigationBarTitleDisplayMode(.large)
    }
}
