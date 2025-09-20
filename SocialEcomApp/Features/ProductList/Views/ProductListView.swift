//
//  ProductListView.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductListViewModel
    var coordinator: ProductListCoordinator //TODO: remove dependency of coordinator from here, this should not have coordinator i think

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Products")
                .onAppear {
                    viewModel.loadInitial()
                }
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
                    VStack(alignment: .leading) {
                        Text(product.title).font(.headline)
                        Text(product.description).font(.subheadline)
                        Text("$\(product.price, specifier: "%.2f")").font(.footnote)
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
