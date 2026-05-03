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
        
        let data: [String: Any?] = [
            "name": name,
            "gender": {
                switch gender {
                case .male: "male"
                case .female: "female"
                case .other: "other"
                case .none: nil
                }
            }(),
            "age": age,
            "country": [
                "isoCode": country?.isoCode,
                "name": country?.name
            ],
            "aboutUs": [
                "source": {
                    switch source {
                    case .instagramFacebook: "instagram_facebook"
                    case .tikTok: "tik_tok"
                    case .youTube: "youtube"
                    case .appStore: "app_store"
                    case .influencer: "influencer"
                    case .friendFamily: "friend_family"
                    case .other: otherSourceText ?? ""
                    case .none: ""
                    }
                }()
            ],
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let documentData = compactDictionary(data)
        try await firestore
            .collection("users")
            .document(uid)
            .collection("onboarding")
            .document("responses")
            .setData(documentData, merge: true)
    }

    // MARK: - Private Methods

    private func compactDictionary(_ dictionary: [String: Any?]) -> [String: Any] {
        dictionary.reduce(into: [:]) { result, element in
            guard let value = element.value else { return }
            if let nestedDictionary = value as? [String: Any?] {
                result[element.key] = compactDictionary(nestedDictionary)
            } else {
                result[element.key] = value
            }
        }
    }
}
