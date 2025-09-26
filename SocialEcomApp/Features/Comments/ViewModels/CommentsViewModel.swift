//
//  ViewState.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import Combine
import Foundation

enum CommentsViewState {
    case idle
    case loading
    case loaded([Comment])
    case error(String)
}

@MainActor
final class CommentsViewModel: ObservableObject {
    @Published var state: CommentsViewState = .idle

    private let dataSource: CommentsDataSourceProtocol

    init(dataSource: CommentsDataSourceProtocol = CommentsDataSource()) {
        self.dataSource = dataSource
    }

    // MARK: - Load All Comments
    func loadComments(for productId: String) {
        state = .loading
        dataSource.loadComments(for: productId) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let comments):
                    // Sort top-level first, replies grouped after
                    let sorted = comments.sorted { $0.createdAt < $1.createdAt }
                    self?.state = .loaded(sorted)
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Add Comment or Reply
    func addComment(_ comment: Comment) {
        dataSource.addComment(comment) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    if case .loaded(var comments) = self?.state {
                        comments.append(comment)
                        // Sort again so new replies go after parent
                        comments.sort { $0.createdAt < $1.createdAt }
                        self?.state = .loaded(comments)
                    } else {
                        // If idle or error, reload fresh
                        self?.loadComments(for: comment.productId)
                    }
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Grouped Comments for UI
    /// Separates top-level comments from replies
    /// Groups replies by their parent comment's ID
    /// - Returns: Tuple of top-level comments and dictionary of replies
    func groupedComments() -> (topLevel: [Comment], replies: [String: [Comment]]) {
        guard case .loaded(let comments) = state else {
            return ([], [:])
        }
        let topLevel = comments.filter { $0.parentId == nil }
        let replies = Dictionary(grouping: comments.filter { $0.parentId != nil }) { $0.parentId! }
        return (topLevel, replies)
    }
}
