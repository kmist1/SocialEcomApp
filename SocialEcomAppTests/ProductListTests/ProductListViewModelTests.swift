//
//  ProductListViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

final class ProductListViewModelTests: XCTestCase {
    private var viewModel: ProductListViewModel!
    private var mockDataSource: MockProductDataSource!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockDataSource = MockProductDataSource()
        viewModel = ProductListViewModel(dataSource: mockDataSource)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockDataSource = nil
        cancellables = nil
        super.tearDown()
    }

    func testSearchFilterReducesProducts() {
        let product1 = Product(id: "1", title: "Red Shirt", description: "Desc", imageUrl: "", price: 20, stock: 5, postedBy: "Admin", createdAt: Date())
        let product2 = Product(id: "2", title: "Blue Jeans", description: "Desc", imageUrl: "", price: 30, stock: 5, postedBy: "Admin", createdAt: Date())

        mockDataSource.mockProducts = [product1, product2]

        let expectation = expectation(description: "Search filter applied")

        viewModel.$state
            .dropFirst() // skip initial idle/loading
            .first { state in
                if case .success(let products) = state, products.count == 1 { return true }
                return false
            }
            .sink { state in
                if case .success(let products) = state {
                    XCTAssertEqual(products.count, 1)
                    XCTAssertEqual(products.first?.title, "Red Shirt")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchText = "Red"
        wait(for: [expectation], timeout: 1.0)
    }

    func testPriceFilterWorks() {
        let cheap = Product(id: "1", title: "Cheap", description: "", imageUrl: "", price: 10, stock: 5, postedBy: "Admin", createdAt: Date())
        let expensive = Product(id: "2", title: "Expensive", description: "", imageUrl: "", price: 300, stock: 5, postedBy: "Admin", createdAt: Date())

        mockDataSource.mockProducts = [cheap, expensive]

        let expectation = expectation(description: "Price filter applied")

        viewModel.$state
            .dropFirst()
            .first { state in
                if case .success(let products) = state, products.count == 1 { return true }
                return false
            }
            .sink { state in
                if case .success(let products) = state {
                    XCTAssertEqual(products.count, 1)
                    XCTAssertEqual(products.first?.title, "Expensive")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.priceFilter = .above(100)
        wait(for: [expectation], timeout: 1.0)
    }
}
