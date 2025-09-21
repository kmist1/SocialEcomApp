//
//  ProductDetailView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI
import Combine

struct ProductDetailView: View {
    @StateObject var viewModel: ProductDetailViewModel
    @State private var showComments = false
    @State private var showShareSheet = false
    private let cartDataSource: CartDataSourceProtocol
    var openChat: () -> Void

    init(
        viewModel: ProductDetailViewModel,
        cartDataSource: CartDataSourceProtocol,
        openChat: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.cartDataSource = cartDataSource
        self.openChat = openChat
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Product Image with Overlay Buttons
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: viewModel.product.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                            }
                            .frame(height: 250)
                            .cornerRadius(12)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .foregroundColor(.gray)
                                .cornerRadius(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    VStack(spacing: 12) {
                        // Share Button
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        // Chat Button
                        Button(action: {
                            openChat()
                        }) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        // Comments Button
                        Button(action: {
                            showComments = true
                        }) {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding([.top, .trailing], 16)
                }

                // MARK: - Title & Price
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.product.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("$\(viewModel.product.price, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // MARK: - Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(viewModel.product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // MARK: - Action Buttons
                Button(action: {
                    cartDataSource.addToCart(viewModel.product)
                }) {
                    HStack {
                        Image(systemName: "cart.fill.badge.plus")
                        Text("Add to Cart")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)

        .sheet(isPresented: $showShareSheet) {
            let shareText = "\(viewModel.product.title)\nPrice: $\(viewModel.product.price)\n\(viewModel.product.description)"
            ShareSheet(activityItems: [shareText])
        }

        .sheet(isPresented: $showComments) {
            CommentListView(productId: viewModel.product.id)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
