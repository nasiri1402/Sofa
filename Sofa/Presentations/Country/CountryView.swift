//
//  CountryView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Lottie
import SwiftUI

struct CountryView: View {

    // MARK: - Public Properties

    @State private(set) var viewModel: CountryViewModel

    // MARK: - Private Properties

    @FocusState private var isSearchFocused: Bool
    @State private var keyboardHeight: CGFloat = .zero

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black090909
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: .zero) {
                TitleText()
                    .padding(.vertical, 16.fitW)

                Tip(text: String(localized: "weWillCreateIdeasForYourCountryMarket"))
                    .padding(.bottom, 16.fitW)

                CountriesScrollView()
            }
            .padding(.horizontal, 16.fitW)
            .overlay(alignment: .bottom) {
                SaveButton()
                    .padding(.horizontal, 16.fitW)
                    .padding(.bottom, keyboardHeight > .zero ? 16.fitW : 47.fitW)
            }
        }
        .navigationTitle(String(localized: "country"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarLeadingButton(icon: .back) {
            viewModel.didTapNavigationBarLeadingButton()
        }
        .contentShape(.rect)
        .onTapGesture {
            isSearchFocused = false
        }
        .onChangeKeyboardHeight { newValue in
            guard newValue != keyboardHeight else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
        }
        .alert(item: $viewModel.alertItem) { item in
            item.alert()
        }
    }

    // MARK: - Views

    private func TitleText() -> some View {
        Text(String(localized: "whereAreYouFrom"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func EmptyStateView() -> some View {
        VStack(alignment: .center, spacing: .zero) {
            LottieView(animation: .named("searching"))
                .looping()
                .resizable()
                .frame(width: 190.fitW, height: 190.fitW)

            Text(String(localized: "nothingFound"))
                .font(.system(size: 34.fitW, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity)
    }

    private func CountriesScrollView() -> some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .center, spacing: 12.fitW) {
                    SearchBar(query: $viewModel.searchInput, isFocused: $isSearchFocused)
                        .padding(.bottom, 4.fitW)

                    if viewModel.displayCountries.isEmpty {
                        EmptyStateView()
                            .padding(.top, 46.fitW)
                    }
                    ForEach(viewModel.displayCountries, id: \.self) { country in
                        CountryButton(country)
                            .id(country.isoCode)
                    }
                }
                .animation(.easeInOut, value: viewModel.selectedCountry)
                .onChange(of: viewModel.selectedCountry) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    withAnimation(oldValue == nil ? nil : .default) {
                        reader.scrollTo(newValue?.isoCode, anchor: .center)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.top, 16.fitW, for: .scrollContent)
            .contentMargins(.bottom, keyboardHeight > .zero ? 84.fitW : 115.fitW, for: .scrollContent)
        }
    }

    private func CountryButton(_ country: CountryModel.Country) -> some View {
        Button {
            viewModel.didTapCountryButton(country)
        } label: {
            HStack(spacing: .zero) {
                Image(country.flag)
                    .resizable()
                    .frame(width: 24.fitW, height: 24.fitW)

                Text(country.name)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15.fitW, weight: .semibold))
                    .foregroundStyle(.grayD1D1D6)
                    .lineLimit(1)

                Spacer(minLength: .zero)
            }
            .padding(14.fitW)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray787880.opacity(0.12))
            .clipShape(.capsule)
            .overlay {
                Capsule()
                    .strokeBorder(.blue007AFF, lineWidth: 1.fitW)
                    .opacity(country == viewModel.selectedCountry ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func SaveButton() -> some View {
        PrimaryButton(title: String(localized: "saveChanges"), onTap: viewModel.didTapSaveButton)
    }
}
