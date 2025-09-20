//
//  CommentServiceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


protocol CommentServiceProtocol {
    func fetchComments(
        productId: String,
        completion: @escaping (Result<[Comment], Error>) -> Void
    )
    func addComment(
        _ comment: Comment,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
