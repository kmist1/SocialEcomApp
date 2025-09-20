//
//  ChatRoomViewModel.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
import Combine
import FirebaseFirestore

final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessage: String = ""

    private let productId: String
    private let service = FirestoreService()
    private var listener: ListenerRegistration?
    let productTitle: String
    let currentUser = "User" + String(Int.random(in: 1...100))// Later, replace with actual signed-in user's ID or name

    init(productId: String, productTitle: String) {
        self.productId = productId
        self.productTitle = productTitle
        listenForMessages()
    }

    func listenForMessages() {
        guard !productId.isEmpty else {
            print("❌ Error: productId is empty. Cannot start Firestore listener.")
            return
        }
        listener = service.listenForMessages(productId: productId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self?.messages = messages
                case .failure(let error):
                    print("Error fetching messages: \(error.localizedDescription)")
                }
            }
        }
    }

    func sendMessage() {
        guard !newMessage.isEmpty, !productId.isEmpty else { return }
        let message = ChatMessage(
            id: UUID().uuidString,
            text: newMessage,
            sender: currentUser, // Replace with real user later
            timestamp: Date()
        )

        service.sendMessage(productId: productId, message: message) { result in
            if case .failure(let error) = result {
                print("Failed to send message: \(error.localizedDescription)")
            }
        }
        newMessage = ""
    }

    deinit {
        listener?.remove()
    }
}
