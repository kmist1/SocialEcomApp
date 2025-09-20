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
        NavigationView {
            List {
                ForEach(viewModel.cartItems, id: \.id) { product in
                    HStack {
                        AsyncImage(url: URL(string: product.imageUrl)) { image in
                            image.resizable()
                                 .scaledToFill()
                                 .frame(width: 50, height: 50)
                                 .cornerRadius(8)
                        } placeholder: {
                            ProgressView().frame(width: 50, height: 50)
                        }

                        VStack(alignment: .leading) {
                            Text(product.title).font(.headline)
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
                }
            }
            .navigationTitle("My Cart")
        }
    }
}
