//
//  CommentListView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

struct CommentListView: View {
    @StateObject private var viewModel = CommentsViewModel()
    @State private var message = ""
    @State private var replyingTo: String? = nil
    @State private var expandedComments: Set<String> = []   // ✅ Track expanded replies
    let productId: String

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Spacer()
                Text("Comments")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding([.bottom, .top], 10)
                Spacer()
                if case .loading = viewModel.state {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()

            // MARK: - Comments Content
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch viewModel.state {
                    case .idle:
                        EmptyCommentsView(message: "No comments yet. Be the first to share your thoughts!")

                    case .loading:
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("Loading comments...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .loaded:
                        let (topLevel, replies) = viewModel.groupedComments()
                        if topLevel.isEmpty {
                            EmptyCommentsView(message: "No comments yet. Be the first to share your thoughts!")
                        } else {
                            ForEach(topLevel, id: \.id) { comment in
                                CommentCard(
                                    comment: comment,
                                    replies: replies[comment.id] ?? [],
                                    expanded: expandedComments.contains(comment.id),
                                    onReply: { parentId in replyingTo = parentId },
                                    onToggleReplies: { parentId in
                                        if expandedComments.contains(parentId) {
                                            expandedComments.remove(parentId)
                                        } else {
                                            expandedComments.insert(parentId)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }

                    case .error(let errorMessage):
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding(.top, 10)
            }

            Divider()

            // MARK: - Replying Banner
            if let parentId = replyingTo,
               let parent = findParentComment(by: parentId) {
                HStack {
                    Text("Replying to \(parent.userId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Cancel") {
                        replyingTo = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
            }

            // MARK: - Input Bar
            HStack(spacing: 10) {
                TextField(replyingTo == nil ? "Add a comment..." : "Add a reply...", text: $message)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                Button {
                    let newComment = Comment(
                        id: UUID().uuidString,
                        productId: productId,
                        userId: "User\(Int.random(in: 1...100))",
                        text: message,
                        createdAt: Date(),
                        parentId: replyingTo
                    )
                    viewModel.addComment(newComment)
                    message = ""
                    replyingTo = nil
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(message.isEmpty ? .gray : .blue)
                }
                .disabled(message.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .onAppear {
            viewModel.loadComments(for: productId)
        }
    }

    // Helper to find parent comment for reply banner
    private func findParentComment(by id: String) -> Comment? {
        if case .loaded(let comments) = viewModel.state {
            return comments.first(where: { $0.id == id })
        }
        return nil
    }
}

// MARK: - Comment Card with Expandable Replies
struct CommentCard: View {
    let comment: Comment
    let replies: [Comment]
    let expanded: Bool
    let onReply: (String) -> Void
    let onToggleReplies: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.userId)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(comment.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.vertical, 2)

            HStack(spacing: 16) {
                Button("Reply") {
                    onReply(comment.id)
                }
                .font(.caption)
                .foregroundColor(.blue)

                if !replies.isEmpty {
                    Button(expanded ? "Hide Replies" : "View Replies (\(replies.count))") {
                        onToggleReplies(comment.id)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // Replies section - only if expanded
            if expanded && !replies.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(replies, id: \.id) { reply in
                        HStack(alignment: .top, spacing: 6) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(reply.userId).font(.caption).fontWeight(.semibold)
                                    Spacer()
                                    Text(reply.createdAt, style: .time).font(.caption2).foregroundColor(.secondary)
                                }
                                Text(reply.text)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.leading, 12)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
