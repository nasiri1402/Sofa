//
//  RemoteStorage.swift
//  Sofa
//
//  Created by dukes on 5/3/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

// MARK: - Interfaces

protocol RemoteStorage {
    func setOnboardingResponses(
        name: String,
        gender: Profile.Gender?,
        age: Int?,
        country: OnboardingModel.Country?,
        source: OnboardingModel.Source?,
        otherSourceText: String?
    ) async throws
}

// MARK: - Implementations

final class DefaultRemoteStorage: RemoteStorage {

    // MARK: - Private Properties

    private let authService: AuthService

    private let firestore = Firestore.firestore()

    // MARK: - Inits

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Public Methods

    func setOnboardingResponses(
        name: String,
        gender: Profile.Gender?,
        age: Int?,
        country: OnboardingModel.Country?,
        source: OnboardingModel.Source?,
        otherSourceText: String?
    ) async throws {
        guard let uid = authService.currentUser()?.uid else { return }

        let document = OnboardingResponsesDocument(
            name: name,
            gender: {
                switch gender {
                case .male: "male"
                case .female: "female"
                case .other: "other"
                case .none: nil
                }
            }(),
            age: age,
            country: {
                guard let country else { return nil }
                return OnboardingResponsesDocument.Country(
                    isoCode: country.isoCode,
                    name: country.name
                )
            }(),
            aboutUs: {
                guard let source else { return nil }
                return OnboardingResponsesDocument.AboutUs(
                    source: {
                        switch source {
                        case .instagramFacebook: "instagram_facebook"
                        case .tikTok: "tik_tok"
                        case .youTube: "youtube"
                        case .appStore: "app_store"
                        case .influencer: "influencer"
                        case .friendFamily: "friend_family"
                        case .other: otherSourceText ?? ""
                        }
                    }()
                )
            }()
        )

        try firestore
            .collection("users")
            .document(uid)
            .collection("onboarding")
            .document("responses")
            .setData(from: document, merge: true)
    }
}
