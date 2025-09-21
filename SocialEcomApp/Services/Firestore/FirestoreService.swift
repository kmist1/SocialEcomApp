//
//  FirestoreProductService.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/19/25.
//


import FirebaseFirestore

class FirestoreService: ProductServiceProtocol {
    private let db = Firestore.firestore()

    func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {

        db.collection("products")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion(.failure(error))
                } else {
                    do {
                        let products = try snapshot?.documents.compactMap {
                            try $0.data(as: Product.self)
                        }
                        completion(.success(products ?? []))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
}

extension FirestoreService: CommentServiceProtocol {

    func fetchComments(
        productId: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    ) {
        db.collection("comments")
            .whereField("productId", isEqualTo: productId)
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let comments = try snapshot?.documents.compactMap {
                            try $0.data(as: Comment.self)
                        }
                        completion(.success(comments ?? []))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }

    func addComment(
        _ comment: Comment,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try db.collection("comments")
                .document(comment.id)
                .setData(from: comment, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: LiveChat services
extension FirestoreService: ChatServiceProtocol {
    // MARK: - Listen for messages in real-time
    func listenForMessages(productId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
        return db.collection("products")
            .document(productId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let messages: [ChatMessage] = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: ChatMessage.self)
                    } ?? []
                    completion(.success(messages))
                }
            }
    }

    // MARK: - Send a message
    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("products")
                .document(productId)
                .collection("messages")
                .document(message.id)
                .setData(from: message) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
}
