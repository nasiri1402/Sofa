//
//  TextFieldAlertItem.swift
//  Sofa
//
//  Created by dukes on 5/10/26.
//

import SwiftUI

struct TextFieldAlertItem: Identifiable {

    // MARK: - Public Properties

    let id = UUID()
    let title: String
    let message: String
    let submitTitle: String
    let placeholder: String
    @Binding var inputText: String
    let onSubmit: () -> Void
}
