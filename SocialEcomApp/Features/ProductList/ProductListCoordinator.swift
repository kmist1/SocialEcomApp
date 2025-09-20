//
//  ProductListCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class ProductListCoordinator {
    func start() -> some View {
        let productDataSource = ProductDataSource()
        let viewModel = ProductListViewModel(dataSource: productDataSource)
        return ProductListView(viewModel: viewModel, coordinator: self)
    }

    func productDetail(for product: Product) -> some View {
        let viewModel = ProductDetailViewModel(product: product)
        return ProductDetailView(viewModel: viewModel)
    }
}
