//
//  MockCommentsDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
import Combine
@testable import SocialEcomApp

class MockCommentsDataSource: CommentsDataSourceProtocol {
    var loadCommentsCallCount = 0
    var addCommentCallCount = 0
    var shouldReturnError = false
    var mockComments: [Comment] = []
    var addedComments: [Comment] = []

    func loadComments(for productId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        loadCommentsCallCount += 1

        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                let filtered = self.mockComments.filter { $0.productId == productId }
                completion(.success(filtered))
            }
        }
    }

    func addComment(_ comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        addCommentCallCount += 1
        addedComments.append(comment)

        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                self.mockComments.append(comment)
                completion(.success(()))
            }
        }
    }
}
