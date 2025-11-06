//
//  LaunchView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct LaunchView: View {

    // MARK: - Public Properties

    @State var viewModel: LaunchViewModel

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.currentStage {
            case .splash: Splash()
            case .onboarding: Onboarding()
            case .tabBar: TabBar()
            }
        }
        .background(.black090909)
        .animation(.easeInOut, value: viewModel.currentStage)
    }

    // MARK: - Subviews

    private func Splash() -> some View {
        SplashView {
            viewModel.didFinishStage(.splash)
        }
        .transition(.opacity)
        .ignoresSafeArea()
    }

    private func Onboarding() -> some View {
        OnboardingView(viewModel: OnboardingViewModel {
            viewModel.didFinishStage(.onboarding)
        })
        .transition(.opacity)
    }

    private func TabBar() -> some View {
        TabBarView(viewModel: TabBarViewModel())
            .transition(.opacity)
    }
}
