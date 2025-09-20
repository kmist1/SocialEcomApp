//
//  ProductDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation
import Combine

final class ProductDataSource: ProductDataSourceProtocol {
    @Published private(set) var products: [Product] = []

    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }

    private let productService: ProductServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // For pagination
    private var currentPage = 1
    private let pageSize = 20
    private var isFetching = false
    private var allLoaded = false

    init(service: ProductServiceProtocol = ServiceFactory.makeProductService()) {
        self.productService = service
    }

    func loadInitial() {
        currentPage = 1
        allLoaded = false
        products = []
        loadMore()
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        guard let currentItem = currentItem else {
            loadMore()
            return
        }

        let thresholdIndex = products.index(products.endIndex, offsetBy: -5)
        if products.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            loadMore()
        }
    }

    private func loadMore() {
        guard !isFetching, !allLoaded else { return }
        isFetching = true

        productService.fetchAllProducts(completion: { [weak self] (result: Result<[Product], Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isFetching = false

                switch result {
                case .success(let newProducts):
                    if newProducts.count < self.pageSize {
                        self.allLoaded = true
                    }
                    self.products.append(contentsOf: newProducts)
                    self.currentPage += 1
                case .failure(let error):
                    print("Failed to fetch products:", error)
                }
            }
        })
    }
}
