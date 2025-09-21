//
//  BackendType.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/19/25.
//

import Foundation

enum BackendType {
    case firestore
    case rest
}

class ServiceFactory {
    static var backend: BackendType = .firestore

    private static let sharedFirestoreService = FirestoreService()

    static func makeProductService() -> ProductServiceProtocol {
        switch backend {
        case .firestore:
            return sharedFirestoreService
        case .rest:
            return RestSubbService() // future product services
        }
    }

    static func makeCommentService() -> CommentServiceProtocol {
        switch backend {
        case .firestore:
            return sharedFirestoreService
        case .rest:
            return RestSubbService() // future comments services
        }
    }

    static func makeLiveChatService() -> ChatServiceProtocol {
        switch backend {
        case .firestore:
            return sharedFirestoreService
        case .rest:
            return RestSubbService() // future comments services
        }
    }

}


class RestSubbService: ProductServiceProtocol, CommentServiceProtocol, ChatServiceProtocol {
    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, any Error>) -> Void) {
    }

    func addComment(_ comment: Comment, completion: @escaping (Result<Void, any Error>) -> Void) {
    }
    
    func fetchAllProducts(completion: @escaping (Result<[Product], any Error>) -> Void) {}
    
    func fetchComments(productId forProductId: String, completion: @escaping (Result<[Comment], any Error>) -> Void) {}
    
}
