//
//  MockCommentsDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
import Combine
@testable import SocialEcomApp

final class MockCommentsDataSource: CommentsDataSourceProtocol {
    var mockComments: [Comment] = []
    var shouldFail = false

    func loadComments(for productId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "TestError", code: -1)))
        } else {
            let filtered = mockComments.filter { $0.productId == productId }
            completion(.success(filtered))
        }
    }

    func addComment(_ comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "TestError", code: -1)))
        } else {
            mockComments.append(comment)
            completion(.success(()))
        }
    }
}
