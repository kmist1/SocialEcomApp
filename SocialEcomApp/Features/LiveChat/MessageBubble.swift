//
//  MessageBubble.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    // Tunable max width so long messages wrap nicely without breaking the row
    private let bubbleMaxWidth: CGFloat = 260

    var body: some View {
        HStack(spacing: 8) {
            if isCurrentUser { Spacer(minLength: 24) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender (optional: hide mine or show "You")
                Text(isCurrentUser ? "You" : message.sender)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .opacity(0.9)

                Text(message.text)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray4))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(12)
                    .frame(maxWidth: bubbleMaxWidth, alignment: isCurrentUser ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true) // allow multi-line growth
            }

            if !isCurrentUser { Spacer(minLength: 24) }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}
