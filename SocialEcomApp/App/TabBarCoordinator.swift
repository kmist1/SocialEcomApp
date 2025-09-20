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
        let cartViewModel = CartViewModel(dataSource: cartDataSource)
        let productListCoordinator = ProductListCoordinator(cartDataSource: cartDataSource)

        return TabView {
            productListCoordinator.start()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            CartView(viewModel: cartViewModel)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }
        }
    }
}
