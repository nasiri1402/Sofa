//
//  CountryView.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

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
                HStack {
                    BackButton()
                    Spacer()
                }
                .padding(.top, 10.fitW)
                .padding(.leading, 16.fitW)

                VStack(alignment: .leading, spacing: .zero) {
                    TitleText()
                        .padding(.vertical, 16.fitW)

                    TipView()
                        .padding(.bottom, 16.fitW)

                    // TODO: Добавить плейсхолдер лотти
                    CountriesScrollView()
                }
                .padding(.horizontal, 16.fitW)
                .overlay(alignment: .bottom) {
                    SaveButton()
                        .padding(.horizontal, 16.fitW)
                        .padding(.bottom, keyboardHeight > .zero ? 16.fitW : 47.fitW)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarVisibility(.hidden, for: .tabBar)
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

    private func BackButton() -> some View {
        Button(action: viewModel.didTapBackButton) {
            Image(.backCircle)
                .resizable()
                .frame(width: 46.fitW, height: 46.fitW)
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    private func TitleText() -> some View {
        Text(String(localized: "whereAreYouFrom"))
            .multilineTextAlignment(.leading)
            .font(.system(size: 34.fitW, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func TipView() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.lamp)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .padding(.trailing, 6.fitW)

            Text(String(localized: "weWillCreateIdeasForYourCountryMarket"))
                .font(.system(size: 13.fitW))
                .foregroundStyle(.grayE5E5EA)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: .zero)
        }
        .padding(.horizontal, 20.fitW)
        .padding(.vertical, 14.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 12.fitW))
    }

    private func CountriesScrollView() -> some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 12.fitW) {
                    SearchBar(query: $viewModel.searchInput, isFocused: $isSearchFocused)
                        .padding(.bottom, 4.fitW)

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
            .scrollBounceBehavior(.always)
            .contentMargins(.top, 16.fitW, for: .scrollContent)
            .contentMargins(.bottom, keyboardHeight > .zero ? 84.fitW : 115.fitW, for: .scrollContent)
        }
    }

    private func CountryButton(_ country: Profile.Country) -> some View {
        Button {
            viewModel.didTapCountryButton(country)
        } label: {
            Text(country.name)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15.fitW, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 20.fitW)
                .frame(height: 48.fitW)
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
