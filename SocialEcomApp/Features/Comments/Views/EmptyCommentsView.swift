//
//  EmptyCommentsView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

struct EmptyCommentsView: View {
    let message: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}
