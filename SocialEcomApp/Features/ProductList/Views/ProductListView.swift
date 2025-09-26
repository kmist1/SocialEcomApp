//
//  ProductListView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel
    var coordinator: ProductListCoordinator

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Products")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
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
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    // Show different messages based on whether user is searching
                    if !viewModel.searchText.isEmpty || viewModel.priceFilter != .all {
                        Text("No products found")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        if !viewModel.searchText.isEmpty {
                            Text("No results for '\(viewModel.searchText)'")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text("Try adjusting your search or filters.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No products available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Check back later for new arrivals.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

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
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text("Error: \(error.localizedDescription)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    viewModel.loadInitial()
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
