//
//  CartCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import SwiftUI

final class CartCoordinator {
    private let cartViewModel: CartViewModel

    init(cartViewModel: CartViewModel) {
        self.cartViewModel = cartViewModel
    }

    func start() -> some View {
        NavigationView {
            CartView(viewModel: cartViewModel)
                .navigationTitle("My Cart")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}