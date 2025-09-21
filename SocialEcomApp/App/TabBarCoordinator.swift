//
//  TabBarCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

final class TabBarCoordinator {
    func start() -> some View {
        let cartDataSource = CartDataSource()
        let productListCoordinator = ProductListCoordinator(cartDataSource: cartDataSource)
        let cartViewModel = CartViewModel(dataSource: cartDataSource)
        let cartCoordinator = CartCoordinator(cartViewModel: cartViewModel)

        return TabBarView(
            productListCoordinator: productListCoordinator,
            cartCoordinator: cartCoordinator,
            cartViewModel: cartViewModel
        )
    }
}

struct TabBarView: View {
    private let productListCoordinator: ProductListCoordinator
    private let cartCoordinator: CartCoordinator
    @StateObject private var cartViewModel: CartViewModel

    init(productListCoordinator: ProductListCoordinator,
         cartCoordinator: CartCoordinator,
         cartViewModel: CartViewModel) {
        self.productListCoordinator = productListCoordinator
        self.cartCoordinator = cartCoordinator
        _cartViewModel = StateObject(wrappedValue: cartViewModel)
    }

    var body: some View {
        TabView {
            productListCoordinator.start()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Shop")
                }

            cartCoordinator.start()
                .tabItem {
                    Image(systemName: "cart.fill")
                        .overlay {
                            if cartViewModel.cartCount > 0 {
                                Text("\(cartViewModel.cartCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -10)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    Text("Cart")
                }
        }
        .animation(.easeInOut, value: cartViewModel.cartCount)
    }
}
