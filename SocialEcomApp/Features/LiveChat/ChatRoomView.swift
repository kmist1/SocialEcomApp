//
//  ChatRoomView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import SwiftUI

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatRoomViewModel
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        VStack {
            // MARK: - Error Banner
            if let error = viewModel.error {
                ErrorBanner(message: error, onRetry: {
                    viewModel.listenForMessages()
                })
                .animation(.easeInOut, value: error)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // MARK: - Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        if viewModel.messages.isEmpty {
                            Text("No messages yet. Start the conversation!")
                                .foregroundColor(.secondary)
                                .padding()
                                .accessibilityIdentifier("emptyMessageText")
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.sender == viewModel.currentUser
                                )
                                .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                }
            }

            // MARK: - Input Field
            HStack {
                TextField("Type a message", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)
                    .accessibilityIdentifier("messageInputField")

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(viewModel.newMessage.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newMessage.isEmpty)
                .accessibilityIdentifier("sendMessageButton")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .navigationTitle(viewModel.productTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Error Banner View
struct ErrorBanner: View {
    let message: String
    let onRetry: () -> Void
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                Text(message)
                    .foregroundColor(.red)
                Spacer()
                Button("Retry") {
                    withAnimation {
                        onRetry()
                    }
                }
                .foregroundColor(.blue)
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal)
        .accessibilityIdentifier("errorBanner")
        .transition(.move(edge: .top))
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
