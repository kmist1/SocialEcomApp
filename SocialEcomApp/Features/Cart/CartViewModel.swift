//
//  CartViewModel.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
import Combine

final class CartViewModel: ObservableObject {
    @Published var cartItems: [Product] = []
    private let dataSource: CartDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(dataSource: CartDataSourceProtocol) {
        self.dataSource = dataSource
        bind()
    }

    private func bind() {
        dataSource.cartItemsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.cartItems, on: self)
            .store(in: &cancellables)
    }

    func removeFromCart(productId: String) {
        dataSource.removeFromCart(productId: productId)
    }
}
