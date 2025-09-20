//
//  CartDataSourceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation

protocol CartDataSourceProtocol {
    var cartItemsPublisher: Published<[Product]>.Publisher { get }
    func addToCart(_ product: Product)
    func removeFromCart(productId: String)
}

import Combine

final class CartDataSource: CartDataSourceProtocol {
    @Published private var cartItems: [Product] = []
    var cartItemsPublisher: Published<[Product]>.Publisher { $cartItems }

    func addToCart(_ product: Product) {
        if !cartItems.contains(where: { $0.id == product.id }) {
            cartItems.append(product)
        }
    }

    func removeFromCart(productId: String) {
        cartItems.removeAll { $0.id == productId }
    }
}
