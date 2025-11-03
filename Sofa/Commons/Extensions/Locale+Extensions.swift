//
//  Locale+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import Foundation

extension Locale {

    // MARK: - Public Methods

    static var currentLanguageName: String? {
        Locale.current.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "")
    }
}
