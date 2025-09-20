//
//  CartDataSourceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation

protocol CartDataSourceProtocol {
    func addToCart(product: Product)
    func getCartItems() -> [Product]
}

final class CartDataSource: CartDataSourceProtocol {
    func addToCart(product: Product) {
        //do nothing
    }
    
    func getCartItems() -> [Product] {
        return []
    }
    
//    private let cartService: CartServiceProtocol
//
//    init(cartService: CartServiceProtocol = CartService()) {
//        self.cartService = cartService
//    }
//
//    func addToCart(product: Product) {
//        cartService.addProductToCart(product)
//    }
//
//    func getCartItems() -> [Product] {
//        cartService.getCartItems()
//    }
}
