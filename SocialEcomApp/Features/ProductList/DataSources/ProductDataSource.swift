//
//  ProductDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation
import Combine

/// A data source responsible for managing product data with pagination support.
/// This class handles loading products in batches, providing infinite scrolling functionality,
/// and publishing updates to its subscribers.
final class ProductDataSource: ProductDataSourceProtocol {
    // MARK: - Published Properties

    /// Array of products that automatically notifies subscribers of changes
    @Published private(set) var products: [Product] = []

    /// Public publisher that emits product array updates
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    /// Service responsible for fetching product data
    private let productService: ProductServiceProtocol

    /// Stores active Combine subscriptions to prevent premature cancellation
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Pagination Properties

    /// Current page number for pagination, starts at 1
    private var currentPage = 1

    /// Number of items to fetch per page
    private let pageSize = 20

    /// Flag to prevent concurrent fetch operations
    private var isFetching = false

    /// Flag indicating whether all available products have been loaded
    private var allLoaded = false

    // MARK: - Initialization

    /// Initializes the data source with a product service
    /// - Parameter service: Service conforming to ProductServiceProtocol, defaults to one created by ServiceFactory
    init(service: ProductServiceProtocol = ServiceFactory.makeProductService()) {
        self.productService = service
    }

    // MARK: - Public Methods

    /// Resets pagination state and loads the initial set of products
    func loadInitial() {
        currentPage = 1
        allLoaded = false
        products = []
        loadMore()
    }

    /// Determines if more products need to be loaded based on the user's scroll position
    /// - Parameter currentItem: The product item currently visible to the user
    ///
    /// Pagination Logic:
    /// 1. If no current item is provided, load more products immediately
    /// 2. If user has scrolled to within 5 items of the end, trigger next page load
    /// 3. Uses product ID comparison to find the current position in the list
    func loadMoreIfNeeded(currentItem: Product?) {
        guard let currentItem = currentItem else {
            loadMore()
            return
        }

        // Create a threshold 5 items from the end
        let thresholdIndex = products.index(products.endIndex, offsetBy: -5)

        // If user has scrolled to the threshold item, load more products
        if products.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            loadMore()
        }
    }

    // MARK: - Private Methods

    /// Fetches the next page of products if conditions allow
    ///
    /// Loading Logic:
    /// 1. Guards against concurrent fetches and checks if all products are loaded
    /// 2. Sets fetching flag to prevent duplicate requests
    /// 3. Calls product service to fetch next page
    /// 4. Updates pagination state based on response
    /// 5. Appends new products to existing array
    /// 6. Updates currentPage for next fetch
    private func loadMore() {
        // Prevent concurrent fetches or loading when all data is retrieved
        guard !isFetching, !allLoaded else { return }
        isFetching = true

        productService.fetchAllProducts(completion: { [weak self] (result: Result<[Product], Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isFetching = false

                switch result {
                case .success(let newProducts):
                    // If received fewer items than page size, we've reached the end
                    if newProducts.count < self.pageSize {
                        self.allLoaded = true
                    }
                    // Append new products and increment page counter
                    self.products.append(contentsOf: newProducts)
                    self.currentPage += 1
                case .failure(let error):
                    print("Failed to fetch products:", error)
                    // TODO: Implement proper error handling and retry mechanism
                }
            }
        })
    }
}
