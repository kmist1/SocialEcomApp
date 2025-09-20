//
//  ProductListCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class ProductListCoordinator {
    private let cartDataSource: CartDataSourceProtocol

    init(cartDataSource: CartDataSourceProtocol) {
        self.cartDataSource = cartDataSource
    }

    func start() -> some View {
        let viewModel = ProductListViewModel()
        return NavigationView {
            ProductListView(viewModel: viewModel, coordinator: self)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    func productDetail(for product: Product) -> some View {
        let viewModel = ProductDetailViewModel(product: product)
        return ProductDetailView(viewModel: viewModel, cartDataSource: cartDataSource)
    }
}
