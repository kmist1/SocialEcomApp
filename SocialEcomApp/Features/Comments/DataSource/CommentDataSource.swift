//
//  CommentDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import Combine
import Foundation

protocol CommentsDataSourceProtocol {
    func loadComments(for productId: String, completion: @escaping (Result<[Comment], Error>) -> Void)
    func addComment(_ comment: Comment, completion: @escaping (Result<Void, Error>) -> Void)
}

final class CommentsDataSource: CommentsDataSourceProtocol {
    private let service: CommentServiceProtocol

    init(service: CommentServiceProtocol = ServiceFactory.makeCommentService()) {
        self.service = service
    }

    func loadComments(for productId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        service.fetchComments(productId: productId, completion: completion)
    }

    func addComment(_ comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        service.addComment(comment, completion: completion)
    }
}
