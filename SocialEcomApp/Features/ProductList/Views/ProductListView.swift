//
//  ProductListView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel = ProductListViewModel()
    var coordinator: ProductListCoordinator //TODO: remove dependency of coordinator from here, this should not have coordinator i think

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Products")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Welcome to the store!")
        case .loading:
            ProgressView("Loading...")
        case .success(let products):
            List(products) { product in
                NavigationLink(
                    destination: coordinator.productDetail(for: product)
                ) {
                    HStack(alignment: .top, spacing: 12) {
                        // Product Image on Leading Side
                        AsyncImage(url: URL(string: product.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(product.title).font(.headline)
                            Text(product.description).font(.subheadline)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                            Text("$\(product.price, specifier: "%.2f")").font(.footnote)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: product)
                }
            }
        case .failure(let error):
            VStack {
                Text("Error: \(error.localizedDescription)")
                Button("Retry") {
                    viewModel.loadInitial()
                }
            }
        }
    }
}
