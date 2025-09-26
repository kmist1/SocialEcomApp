//
//  ProductListCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class ProductListCoordinator {
    // MARK: - Properties
    private let cartDataSource: CartDataSourceProtocol
    private var viewModel: ProductListViewModel?  // Strong reference to own ViewModel lifecycle

    // MARK: - Initialization
    init(cartDataSource: CartDataSourceProtocol) {
        self.cartDataSource = cartDataSource
    }

    // MARK: - Navigation
    func start() -> some View {
        // Create and retain ViewModel with proper dependencies
        let viewModel = ProductListViewModel(
            dataSource: ProductDataSource()
        )
        self.viewModel = viewModel

        return NavigationView {
            ProductListView(viewModel: viewModel, coordinator: self)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    func productDetail(for product: Product) -> some View {
        let detailCoordinator = ProductDetailCoordinator(
            product: product,
            cartDataSource: cartDataSource
        )
        return detailCoordinator.start()
    }
}
