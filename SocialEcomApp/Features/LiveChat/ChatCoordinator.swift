//
//  ChatCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

final class ChatCoordinator {
    func start() -> some View {
        let viewModel = ChatViewModel()
        return NavigationView {
            ChatTabView(viewModel: viewModel)
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
