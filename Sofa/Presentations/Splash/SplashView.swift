//
//  SplashView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct SplashView: View {

    // MARK: - Public Properties

    let onFinish: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 40.fitW) {
            Image(.launchLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 135, height: 135)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.black090909)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    onFinish()
                }
            }
        }
        .contentShape(.rect)
    }
}
