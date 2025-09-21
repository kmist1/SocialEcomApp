//
//  ProductDetailCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import SwiftUI

final class ProductDetailCoordinator {
    private let product: Product
    private let cartDataSource: CartDataSourceProtocol

    init(product: Product, cartDataSource: CartDataSourceProtocol) {
        self.product = product
        self.cartDataSource = cartDataSource
    }

    func start() -> some View {
        CoordinatorView(
            product: product,
            cartDataSource: cartDataSource
        )
    }

    private struct CoordinatorView: View {
        let product: Product
        let cartDataSource: CartDataSourceProtocol
        @State private var isChatOpen = false

        var body: some View {
            ProductDetailView(
                viewModel: ProductDetailViewModel(product: product),
                cartDataSource: cartDataSource,
                openChat: { isChatOpen = true }
            )
            .background(
                NavigationLink(
                    destination: ChatCoordinator().start(
                        productId: product.id,
                        productTitle: product.title
                    ),
                    isActive: $isChatOpen
                ) { EmptyView() }
            )
        }
    }
}
