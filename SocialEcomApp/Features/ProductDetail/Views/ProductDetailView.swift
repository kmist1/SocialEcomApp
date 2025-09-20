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
    @State private var isChatOpen = false
    @State private var showComments = false   // ✅ State for bottom sheet
    private let cartDataSource: CartDataSourceProtocol

    init(viewModel: ProductDetailViewModel, cartDataSource: CartDataSourceProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.cartDataSource = cartDataSource
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Product Image
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

                // MARK: - Add to Cart Button
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

                // MARK: - Chat Button
                NavigationLink(
                    destination: ChatCoordinator().start(
                        productId: viewModel.product.id,
                        productTitle: viewModel.product.title
                    ),
                    isActive: $isChatOpen
                ) {
                    EmptyView()
                }

                Button(action: {
                    isChatOpen = true
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Open Chat")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
                .padding(.horizontal)

                // MARK: - View Comments Button
                Button(action: {
                    showComments = true
                }) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                        Text("View Comments")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
        // ✅ Bottom sheet for comments
        .sheet(isPresented: $showComments) {
            CommentListView(productId: viewModel.product.id)
                .presentationDetents([.medium, .large])  // iOS 16+ sheet sizes
                .presentationDragIndicator(.visible)
        }
    }
}
