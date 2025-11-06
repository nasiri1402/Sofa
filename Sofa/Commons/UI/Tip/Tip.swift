//
//  Tip.swift
//  Sofa
//
//  Created by dukes on 11/6/25.
//

import SwiftUI

struct Tip: View {

    // MARK: - Public Properties

    let text: String

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(.lamp)
                .resizable()
                .frame(width: 24.fitW, height: 24.fitW)
                .padding(.trailing, 6.fitW)

            Text(text)
                .font(.system(size: 13.fitW))
                .foregroundStyle(.grayE5E5EA)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 24.fitW)

            Spacer(minLength: .zero)
        }
        .padding(.horizontal, 20.fitW)
        .padding(.vertical, 14.fitW)
        .background(.gray787880.opacity(0.12))
        .clipShape(.rect(cornerRadius: 12.fitW))
    }
}
