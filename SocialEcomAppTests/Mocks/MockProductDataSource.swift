//
//  MockProductDataSource.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation
@testable import SocialEcomApp
import Combine

final class MockProductDataSource: ProductDataSourceProtocol {
    private let productsSubject = CurrentValueSubject<[Product], Never>([])
    var shouldFail = false
    var productsPublisher: AnyPublisher<[Product], Never> {
        productsSubject.eraseToAnyPublisher()
    }

    var mockProducts: [Product] = [] {
        didSet { productsSubject.send(mockProducts) }
    }

    func loadInitial() {
        productsSubject.send(mockProducts)
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        // For test simplicity, send same products
        productsSubject.send(mockProducts)
    }
}
