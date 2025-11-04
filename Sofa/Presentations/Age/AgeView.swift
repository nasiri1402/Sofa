//
//  AgeView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct AgeView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: AgeViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10.fitW) {
                TitleText()
            }
            .padding(.horizontal, 16.fitW)
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationBarLeadingButton(icon: .back, action: viewModel.didTapNavigationBarLeadingButton)
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(String(localized: "howOldAreYou"))
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
    }
}
