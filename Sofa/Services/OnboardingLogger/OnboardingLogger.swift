//
//  OnboardingLogger.swift
//  Sofa
//
//  Created by Codex on 4/16/26.
//

import Foundation

// MARK: - Interfaces

protocol OnboardingLogger {
    func logResponses(
        name: String,
        gender: Profile.Gender?,
        age: Int?,
        country: OnboardingModel.Country?,
        source: OnboardingModel.Source?,
        otherSourceText: String?
    ) async throws
}

// MARK: - Implementations

final class DefaultOnboardingLogger: OnboardingLogger {

    // MARK: - Private Properties

    private let functionsClient: FunctionsClient

    // MARK: - Inits

    init(functionsClient: FunctionsClient) {
        self.functionsClient = functionsClient
    }

    // MARK: - Public Methods

    func logResponses(
        name: String,
        gender: Profile.Gender?,
        age: Int?,
        country: OnboardingModel.Country?,
        source: OnboardingModel.Source?,
        otherSourceText: String?
    ) async throws {
        let request = OnboardingResponsesRequest(
            name: OnboardingResponsesRequest.Name(name: name),
            gender: OnboardingResponsesRequest.Gender(
                gender: {
                    switch gender {
                    case .male: "male"
                    case .female: "female"
                    case .other: "other"
                    case .none: nil
                    }
                }()
            ),
            age: OnboardingResponsesRequest.Age(age: age),
            country: OnboardingResponsesRequest.Country(
                isoCode: country?.isoCode,
                name: country?.name
            ),
            aboutUs: OnboardingResponsesRequest.AboutUs(
                source: {
                    switch source {
                    case .instagramFacebook: "instagram_facebook"
                    case .tikTok: "tik_tok"
                    case .youTube: "youtube"
                    case .appStore: "app_store"
                    case .influencer: "influencer"
                    case .friendFamily: "friend_family"
                    case .other: "other"
                    case .none: nil
                    }
                }(),
                other: otherSourceText
            )
        )
        try await functionsClient.onboardingResponses(request: request)
    }
}
