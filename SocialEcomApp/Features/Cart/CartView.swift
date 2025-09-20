//
//  CartView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        Group {
            if viewModel.cartItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.6))

                    Text("Your Cart is Empty")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Browse products and add them to your cart!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(viewModel.cartItems, id: \.id) { product in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(6)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }

                            VStack(alignment: .leading) {
                                Text(product.title)
                                    .font(.headline)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }

                            Spacer()

                            Button(action: {
                                viewModel.removeFromCart(productId: product.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
    }
}
