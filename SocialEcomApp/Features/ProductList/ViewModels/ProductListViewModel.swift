//
//  ProductListViewModel.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//
import Foundation
import Combine

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

/// Price filter buckets. Adjust as needed.
enum PriceFilter: Equatable {
    case all
    case under(Double)            // e.g. < 50
    case between(Double, Double)  // e.g. 50...200
    case above(Double)            // e.g. > 200
}

final class ProductListViewModel: ObservableObject {
    // MARK: - Inputs (filters/search)
    @Published var searchText: String = ""
    @Published var priceFilter: PriceFilter = .all
    // NOTE: category filter omitted because `Product` has no category field yet.

    // MARK: - Outputs (for the View)
    @Published private(set) var state: ViewState<[Product]> = .idle

    // MARK: - Internals
    private let dataSource: ProductDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()

    // Keep a cache of "all loaded so far" from the datasource.
    private var allProducts: [Product] = []

    init(dataSource: ProductDataSourceProtocol = ProductDataSource()) {
        self.dataSource = dataSource
        bind()
        loadInitial()
    }

    // MARK: - Public API used by the View
    func loadInitial() {
        state = .loading
        dataSource.loadInitial()
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        dataSource.loadMoreIfNeeded(currentItem: currentItem)
    }

    // MARK: - Private
    private func bind() {
        // 1) Keep track of products coming from the data source.
        let productsStream = dataSource.productsPublisher
            .handleEvents(receiveOutput: { [weak self] products in
                self?.allProducts = products
            })

        // 2) Combine products with filters to compute the visible list.
        Publishers.CombineLatest3(
            productsStream,
            $searchText.removeDuplicates(),
            $priceFilter.removeDuplicates()
        )
        .map { [weak self] products, search, priceFilter in
            self?.applyFilters(products: products, search: search, priceFilter: priceFilter) ?? []
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] filtered in
            guard let self = self else { return }
            if filtered.isEmpty {
                // If no items at all have loaded, prefer .idle; if items loaded but filtered to zero, still show empty list.
                if self.allProducts.isEmpty {
                    self.state = .idle
                } else {
                    self.state = .success([]) // empty after filtering
                }
            } else {
                self.state = .success(filtered)
            }
        }
        .store(in: &cancellables)
    }

    private func applyFilters(products: [Product],
                              search: String,
                              priceFilter: PriceFilter) -> [Product] {
        var output = products

        // Search by title (name)
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let needle = search.lowercased()
            output = output.filter { $0.title.lowercased().contains(needle) }
        }

        // Price filter
        switch priceFilter {
        case .all:
            break
        case .under(let max):
            output = output.filter { $0.price < max }
        case .between(let min, let max):
            output = output.filter { $0.price >= min && $0.price <= max }
        case .above(let min):
            output = output.filter { $0.price > min }
        }

        return output
    }
}
