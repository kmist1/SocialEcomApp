//
//  CartDataSourceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation

protocol CartDataSourceProtocol {
    var cartItemsPublisher: Published<[Product]>.Publisher { get }
    var cartCountPublisher: Published<Int>.Publisher { get }
    func addToCart(_ product: Product)
    func removeFromCart(productId: String)
}

import Combine

final class CartDataSource: CartDataSourceProtocol {
    @Published private var cartItems: [Product] = []
    var cartItemsPublisher: Published<[Product]>.Publisher { $cartItems }
    var cartCountPublisher: Published<Int>.Publisher { $cartCount }

    @Published private var cartCount: Int = 0

    func addToCart(_ product: Product) {
        if !cartItems.contains(where: { $0.id == product.id }) {
            cartItems.append(product)
            cartCount = cartItems.count
        }
    }

    func removeFromCart(productId: String) {
        cartItems.removeAll { $0.id == productId }
        cartCount = cartItems.count
    }
}
