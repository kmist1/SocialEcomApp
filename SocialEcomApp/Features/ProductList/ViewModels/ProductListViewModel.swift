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

final class ProductListViewModel: ObservableObject {
    @Published var state: ViewState<[Product]> = .idle

    private let dataSource: ProductDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(dataSource: ProductDataSourceProtocol = ProductDataSource()) {
        self.dataSource = dataSource
        bind()
        loadInitial()
    }

    func loadInitial() {
        state = .loading
        dataSource.loadInitial() // Triggers fetch
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        dataSource.loadMoreIfNeeded(currentItem: currentItem)
    }

    private func bind() {
        dataSource.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                if products.isEmpty {
                    self.state = .idle
                } else {
                    // Always assign to trigger UI even if same products
                    self.state = .success(products)
                }
            }
            .store(in: &cancellables)
    }
}
