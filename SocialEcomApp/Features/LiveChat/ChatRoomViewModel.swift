//
//  ChatRoomViewModel.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
import Combine
import FirebaseFirestore

protocol ChatServiceProtocol {
    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, Error>) -> Void)
    func listenForMessages(productId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration
}

final class ChatRoomViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessage: String = ""
    @Published var error: String?

    private let productId: String
    private let service: ChatServiceProtocol
    private var listener: ListenerRegistration?
    let productTitle: String
    let currentUser: String

    init(productId: String,
         productTitle: String,
         currentUser: String? = nil,
         service: ChatServiceProtocol = ServiceFactory.makeLiveChatService()) {
        self.productId = productId
        self.productTitle = productTitle
        self.currentUser = currentUser ?? "User\(Int.random(in: 1...100))"
        self.service = service
        listenForMessages()
    }

    func listenForMessages() {
        guard !productId.isEmpty else {
            error = "Product ID cannot be empty"
            return
        }

        listener = service.listenForMessages(productId: productId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
                    self?.error = nil
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !productId.isEmpty else {
            error = "Product ID cannot be empty"
            return
        }

        let messageText = newMessage
        let message = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            sender: currentUser,
            timestamp: Date()
        )

        newMessage = "" // Clear message field immediately for better UX

        service.sendMessage(productId: productId, message: message) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.error = nil
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
