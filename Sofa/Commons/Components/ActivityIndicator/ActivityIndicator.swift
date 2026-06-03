//
//  ActivityIndicator.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct ActivityIndicator: View {

    // MARK: - Public Properties

    let isLoading: Bool

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.8)
                .blur(radius: 8.fitW)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)
                .progressViewStyle(.circular)
                .tint(.blue007AFF)
                .padding(40.fitW)
        }
        .onTapGesture {}
        .opacity(isLoading ? 1 : .zero)
        .animation(.easeInOut, value: isLoading)
    }
}
