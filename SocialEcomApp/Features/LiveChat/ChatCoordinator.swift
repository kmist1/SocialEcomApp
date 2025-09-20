//
//  ChatCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

final class ChatCoordinator {
    func start(productId: String, productTitle: String) -> some View {
        let viewModel = ChatRoomViewModel(productId: productId, productTitle: productTitle)
        return NavigationView {
            ChatRoomView(viewModel: viewModel)
                .navigationTitle(productTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

class ChatViewModel {}

struct ChatTabView: View {

    var viewModel: ChatViewModel
    var body: some View {
        Text("Hello chat")
    }
}
