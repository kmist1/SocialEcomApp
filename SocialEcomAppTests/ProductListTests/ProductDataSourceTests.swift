//
//  ProductDataSourceTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

final class ProductDataSourceTests: XCTestCase {

    private var mockDataSource: MockProductDataSource!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockDataSource = MockProductDataSource()
        cancellables = []
    }

    override func tearDown() {
        mockDataSource = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadInitialProducts() {
        // Given
        let product = Product(
            id: "1",
            title: "Test Product",
            description: "Test Description",
            imageUrl: "",
            price: 100.0,
            stock: 10,
            postedBy: "Admin",
            createdAt: Date()
        )
        mockDataSource.mockProducts = [product]

        // Expectation for publisher
        let expectation = XCTestExpectation(description: "Initial products loaded")

        // When
        mockDataSource.productsPublisher
            .sink { products in
                if !products.isEmpty {
                    XCTAssertEqual(products.count, 1)
                    XCTAssertEqual(products.first?.title, "Test Product")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockDataSource.loadInitial()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadMoreProducts() {
        // Given
        let product1 = Product(id: "1", title: "Product 1", description: "Desc1", imageUrl: "", price: 50, stock: 5, postedBy: "Admin", createdAt: Date())
        let product2 = Product(id: "2", title: "Product 2", description: "Desc2", imageUrl: "", price: 75, stock: 8, postedBy: "Admin", createdAt: Date())
        mockDataSource.mockProducts = [product1]

        let expectation = XCTestExpectation(description: "More products loaded")
        var received: [Product] = []

        mockDataSource.productsPublisher
            .sink { products in
                received = products
                if products.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Load initial, then load more
        mockDataSource.loadInitial()
        mockDataSource.mockProducts = [product1, product2]
        mockDataSource.loadMoreIfNeeded(currentItem: product1)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(received.count, 2)
    }

    func testEmptyProducts() {
        // Given
        mockDataSource.mockProducts = []

        let expectation = XCTestExpectation(description: "No products loaded")

        mockDataSource.productsPublisher
            .sink { products in
                if products.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        mockDataSource.loadInitial()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testFailureScenario() {
        // Given
        mockDataSource.shouldFail = true

        let expectation = XCTestExpectation(description: "Failure scenario handled")

        mockDataSource.productsPublisher
            .sink { products in
                if products.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        mockDataSource.loadInitial()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
