//
//  ProductDetailViewModel.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import Foundation
import Combine

import Foundation
import Combine

final class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var isAddedToCart = false

    private let cartDataSource: CartDataSourceProtocol

    init(product: Product, cartDataSource: CartDataSourceProtocol = CartDataSource()) {
        self.product = product
        self.cartDataSource = cartDataSource
    }

    func addToCart() {
        cartDataSource.addToCart(product)
        isAddedToCart = true
    }
}
