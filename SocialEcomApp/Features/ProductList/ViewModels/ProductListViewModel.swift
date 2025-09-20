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

    init(dataSource: ProductDataSourceProtocol) {
        self.dataSource = dataSource
        bind()
        loadInitial()
    }

    func loadInitial() {
        state = .loading
        dataSource.loadInitial()
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        dataSource.loadMoreIfNeeded(currentItem: currentItem)
    }

    private func bind() {
        dataSource.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                if products.isEmpty {
                    self?.state = .idle
                } else {
                    self?.state = .success(products)
                }
            }
            .store(in: &cancellables)
    }
}
