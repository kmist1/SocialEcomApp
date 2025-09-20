//
//  ProductListView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel = ProductListViewModel()
    var coordinator: ProductListCoordinator

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Products")
                .navigationBarTitleDisplayMode(.inline)
                // ✅ Move toolbar here so it only applies on this screen
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            // Price filter options
                            Button("All prices") { viewModel.priceFilter = .all }
                            Button("Under $50") { viewModel.priceFilter = .under(50) }
                            Button("$50 – $200") { viewModel.priceFilter = .between(50, 200) }
                            Button("Above $200") { viewModel.priceFilter = .above(200) }
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
        }
        // Search bar stays here because it's tied to the list screen only
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            VStack(spacing: 12) {
                Text("Welcome to the store!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Use the search and filters to find products.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loading:
            ProgressView("Loading products...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success(let products):
            if products.isEmpty {
                // Empty AFTER filtering
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No products match your filters.")
                        .foregroundColor(.secondary)
                    Button("Clear Filters") {
                        viewModel.searchText = ""
                        viewModel.priceFilter = .all
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(products) { product in
                    NavigationLink(
                        destination: coordinator.productDetail(for: product)
                    ) {
                        HStack(alignment: .top, spacing: 12) {
                            // Leading image
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
                                        .clipped()
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

                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                Text(product.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: product)
                    }
                }
                .listStyle(.plain)
            }

        case .failure(let error):
            VStack(spacing: 12) {
                Text("Error: \(error.localizedDescription)")
                Button("Retry") {
                    viewModel.loadInitial()
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
