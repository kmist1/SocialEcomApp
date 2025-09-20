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

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() } // push current user's bubble to the right

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)

                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray4))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(12)
                    .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            }

            if !isCurrentUser { Spacer() } // push other user's bubble to the left
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}
