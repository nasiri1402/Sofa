//
//  TabBarView.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

struct TabBarView: View {

    // MARK: - State

    @State var viewModel: TabBarViewModel

    // MARK: - Body

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            GeneratorTab()
            InProcessTab()
            SettingsTab()
        }
    }

    // MARK: - Views

    private func GeneratorTab() -> some View {
        NavigationStack {
            GeneratorView()
        }
        .tabItem {
            TabItem(.generator)
        }
        .tag(TabBarModel.Tab.generator)
    }

    private func InProcessTab() -> some View {
        NavigationStack {
            InProcessView()
        }
        .tabItem {
            TabItem(.inProcess)
        }
        .tag(TabBarModel.Tab.inProcess)
    }

    private func SettingsTab() -> some View {
        NavigationStack {
            SettingsView(viewModel: SettingsViewModel(
                storeManager: ServiceLayer.storeManager
            ))
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
