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
        VStack(alignment: .center) {
            Image(.splashLogo)
                .resizable()
                .frame(width: 135, height: 135)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue007AFF)
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onFinish()
                }
            }
        }
    }
}
