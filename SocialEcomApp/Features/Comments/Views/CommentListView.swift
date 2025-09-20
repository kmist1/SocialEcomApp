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
    let productId: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Comments")
                .font(.headline)

            switch viewModel.state {
            case .idle:
                Text("No comments yet.")
                    .padding()

            case .loading:
                ProgressView("Loading comments...")
                    .padding()

            case .loaded(let comments):
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(comments, id: \.id) { comment in
                            VStack(alignment: .leading) {
                                Text(comment.text)
                                    .bold()
                                Text("- UserId: \(comment.userId)")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

            case .error(let errorMessage):
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }

            HStack {
                TextField("Add comment...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    let newComment = Comment(
                        id: UUID().uuidString,
                        productId: productId,
                        userId: String(Int.random(in: 1...100)),
                        text: message,
                        createdAt: Date()
                    )
                    viewModel.addComment(newComment)
                    message = ""
                }
                .disabled(message.isEmpty)
            }
        }
        .padding()
        .onAppear {
            viewModel.loadComments(for: productId)
        }
    }
}
