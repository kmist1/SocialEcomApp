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
            // MARK: - Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.sender == viewModel.currentUser
                            )
                            .id(message.id)
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

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newMessage.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .navigationTitle(viewModel.productTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
