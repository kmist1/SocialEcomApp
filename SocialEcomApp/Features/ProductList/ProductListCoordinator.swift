//
//  ProductListCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class ProductListCoordinator {
    func start() -> some View {
        return ProductListView(coordinator: self)
    }

    func productDetail(for product: Product) -> some View {
        let viewModel = ProductDetailViewModel(product: product)
        return ProductDetailView(viewModel: viewModel)
    }
}
