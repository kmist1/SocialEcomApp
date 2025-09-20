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

    func loadComments(for productId: String) {
        state = .loading
        dataSource.loadComments(for: productId) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let comments):
                    self?.state = .loaded(comments)
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func addComment(_ comment: Comment) {
        dataSource.addComment(comment) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    if case .loaded(var comments) = self?.state {
                        comments.append(comment)
                        self?.state = .loaded(comments)
                    }
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
