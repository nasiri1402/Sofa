//
//  TabBarView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct TabBarView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: TabBarViewModel

    // MARK: - Private Properties

    @State private var generatorRouter = GeneratorRouter()
    @State private var plansRouter = PlansRouter()
    @State private var settingsRouter = SettingsRouter()
    @State private var isTabBarHidden = false

    // MARK: - Body

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            GeneratorTab()
            PlansTab()
            SettingsTab()
        }
        .toolbarVisibility(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .environment(\.isTabBarHidden, $isTabBarHidden)
    }

    // MARK: - Views

    private func GeneratorTab() -> some View {
        NavigationStack(path: $generatorRouter.path) {
            GeneratorView(viewModel: GeneratorViewModel(
                router: generatorRouter,
                storeManager: ServiceLayer.storeManager,
                dataStorage: ServiceLayer.dataStorage
            ))
            .toolbarVisibility(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .navigationDestination(for: AnyRouter.self) { router in
                router.makeView()
            }
        }
        .tabItem {
            TabItem(.generator)
        }
        .tag(TabBarModel.Tab.generator)
    }

    private func PlansTab() -> some View {
        NavigationStack(path: $plansRouter.path) {
            PlansView(viewModel: PlansViewModel(
                router: plansRouter,
                dataStorage: ServiceLayer.dataStorage
            ))
            .toolbarVisibility(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .navigationDestination(for: AnyRouter.self) { router in
                router.makeView()
            }
        }
        .tabItem {
            TabItem(.plans)
        }
        .tag(TabBarModel.Tab.plans)
    }

    private func SettingsTab() -> some View {
        NavigationStack(path: $settingsRouter.path) {
            SettingsView(viewModel: SettingsViewModel(
                router: settingsRouter,
                storeManager: ServiceLayer.storeManager
            ))
            .toolbarVisibility(isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .navigationDestination(for: AnyRouter.self) { router in
                router.makeView()
            }
        }
        .tabItem {
            TabItem(.settings)
        }
        .tag(TabBarModel.Tab.settings)
    }

    private func TabItem(_ tab: TabBarModel.Tab) -> some View {
        VStack(spacing: 4.fitW) {
            Image(tab == viewModel.selectedTab ? tab.selectedIcon : tab.unselectedIcon)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)

            Text(tab.title)
                .font(.system(size: 11.fitW))
                .foregroundStyle(tab == viewModel.selectedTab ? .blue007AFF : .gray8E8E93)
                .frame(height: 13.fitW)
        }
    }
}
