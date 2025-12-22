//
//  OnboardingCountryPage.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import Lottie
import SwiftUI

struct OnboardingCountryPage: View {

    // MARK: - Public Properties

    @Binding var selectedCountry: OnboardingModel.Country?
    let countries: [OnboardingModel.Country]
    @Binding var searchInput: String
    @Binding var isPreviousEnabled: Bool
    @Binding var isNextEnabled: Bool
    let needsReveal: Bool

    // MARK: - Private Properties

    @FocusState private var isSearchFocused
    @State private var isSelectionEnabled = false
    @State private var topPadding: CGFloat = 256.fitH
    @State private var keyboardHeight: CGFloat = .zero
    @State private var transitionTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16.fitW) {
            if needsReveal {
                WordRevealText(
                    text: String(localized: "whereAreYouFrom"),
                    font: .system(size: 34.fitW, weight: .bold),
                    onFinished: completeTitleReveal
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(String(localized: "whereAreYouFrom"))
                    .font(.system(size: 34.fitW, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isSelectionEnabled {
                VStack(alignment: .leading, spacing: 16.fitW) {
                    Tip(text: String(localized: "weWillCreateIdeasForYourCountryMarket"))
                    CountriesScrollView()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer(minLength: .zero)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16.fitW)
        .transition(.opacity)
        .contentShape(.rect)
        .onTapGesture {
            isSearchFocused = false
        }
        .onAppear {
            if needsReveal {
                isSelectionEnabled = false
                topPadding = 256.fitH
            } else {
                isSelectionEnabled = true
                topPadding = 72.fitW
            }
        }
        .onDisappear {
            transitionTask?.cancel()
        }
        .onChangeKeyboardHeight { newValue in
            guard newValue != keyboardHeight else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = newValue
            }
        }
    }

    // MARK: - Views

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
                    SearchBar(query: $searchInput, isFocused: $isSearchFocused)
                        .padding(.bottom, 4.fitW)

                    if countries.isEmpty {
                        EmptyStateView()
                            .padding(.top, 46.fitW)
                    }
                    ForEach(countries, id: \.self) { country in
                        CountryButton(country)
                            .id(country.isoCode)
                    }
                }
                .animation(.easeInOut, value: selectedCountry)
                .onChange(of: selectedCountry) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    withAnimation {
                        reader.scrollTo(newValue?.isoCode, anchor: .center)
                    }
                }
                .onAppear {
                    reader.scrollTo(selectedCountry?.isoCode, anchor: .center)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .contentMargins(.top, 16.fitW, for: .scrollContent)
            .contentMargins(
                .bottom,
                selectedCountry == nil
                ? 16.fitW
                : keyboardHeight > .zero ? 84.fitW : 115.fitW,
                for: .scrollContent
            )
        }
    }

    private func CountryButton(_ country: CountryModel.Country) -> some View {
        Button {
            selectedCountry = selectedCountry == country ? nil : country
        } label: {
            HStack(spacing: .zero) {
                Image(country.flag)
                    .resizable()
                    .frame(width: 24.fitW, height: 24.fitW)
                    .padding(.trailing, 10.fitW)

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
                    .opacity(country == selectedCountry ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .hapticFeedback()
    }

    // MARK: - Private Methods

    @MainActor
    private func completeTitleReveal() {
        isPreviousEnabled = true
        isNextEnabled = true
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            withAnimation(.easeInOut) {
                topPadding = 72.fitW
                isSelectionEnabled = true
            }
        }
    }
}
