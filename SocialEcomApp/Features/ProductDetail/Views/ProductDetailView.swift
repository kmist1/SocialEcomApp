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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.product.title).font(.title)
            Text(viewModel.product.description)
            Text("Price: $\(viewModel.product.price, specifier: "%.2f")")

            Button(action: {
                viewModel.addToCart()
            }) {
                Text(viewModel.isAddedToCart ? "Added to Cart" : "Add to Cart")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            CommentListView(productId: viewModel.product.id)
        }
        .padding()
        .navigationTitle("Product Detail")
    }
}
