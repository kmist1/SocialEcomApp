//
//  MockCartDataSourceForDetail.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//
import Foundation
import Combine
@testable import SocialEcomApp

final class MockCartDataSourceForDetail: CartDataSourceProtocol {
    @Published private(set) var cartItems: [Product] = []
    @Published private(set) var cartCount: Int = 0
    var cartItemsPublisher: Published<[Product]>.Publisher { $cartItems }
    var cartCountPublisher: Published<Int>.Publisher { $cartCount }

    func addToCart(_ product: Product) {
        cartItems.append(product)
        cartCount = cartItems.count
    }

    func removeFromCart(productId: String) {
        cartItems.removeAll { $0.id == productId }
        cartCount = cartItems.count
    }
}
