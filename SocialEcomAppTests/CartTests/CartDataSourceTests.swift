//
//  CartDataSourceTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

final class CartDataSourceTests: XCTestCase {
    private var cartDataSource: CartDataSource!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cartDataSource = CartDataSource()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cartDataSource = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState_IsEmpty() {
        // Test both publishers initially emit empty states
        let expectation1 = expectation(description: "Cart items is empty")
        let expectation2 = expectation(description: "Cart count is zero")

        cartDataSource.cartItemsPublisher
            .sink { items in
                XCTAssertTrue(items.isEmpty)
                expectation1.fulfill()
            }
            .store(in: &cancellables)

        cartDataSource.cartCountPublisher
            .sink { count in
                XCTAssertEqual(count, 0)
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation1, expectation2], timeout: 1.0)
    }

    func testAddToCart_NewProduct_AddsSuccessfully() {
        let product = Product(id: "1", title: "Test Product", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())

        let itemsExpectation = expectation(description: "Cart items updated")
        let countExpectation = expectation(description: "Cart count updated")

        cartDataSource.cartItemsPublisher
            .dropFirst() // Skip initial empty state
            .sink { items in
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items.first?.id, "1")
                itemsExpectation.fulfill()
            }
            .store(in: &cancellables)

        cartDataSource.cartCountPublisher
            .dropFirst() // Skip initial zero state
            .sink { count in
                XCTAssertEqual(count, 1)
                countExpectation.fulfill()
            }
            .store(in: &cancellables)

        cartDataSource.addToCart(product)
        wait(for: [itemsExpectation, countExpectation], timeout: 1.0)
    }

    func testAddToCart_DuplicateProduct_NotAdded() {
        let product = Product(id: "1", title: "Test Product", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())

        let expectation = expectation(description: "Cart updates received")
        var updateCount = 0

        cartDataSource.cartItemsPublisher
            .sink { items in
                updateCount += 1
                if updateCount == 2 { // Initial empty + first add
                    XCTAssertEqual(items.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Add same product twice
        cartDataSource.addToCart(product)
        cartDataSource.addToCart(product)

        wait(for: [expectation], timeout: 1.0)
    }

    func testRemoveFromCart_NonexistentProduct_NoEffect() {
        let product = Product(id: "1", title: "Test Product", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())
        cartDataSource.addToCart(product)

        let expectation = expectation(description: "Cart remains unchanged")
        var updates = 0

        cartDataSource.cartItemsPublisher
            .dropFirst() // Skip initial empty state
            .sink { items in
                updates += 1
                if updates == 1 {
                    XCTAssertEqual(items.count, 1) // Still has original product
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        cartDataSource.removeFromCart(productId: "nonexistent-id")
        wait(for: [expectation], timeout: 1.0)
    }

    func testMultipleProducts_MaintainsOrder() {
        let product1 = Product(id: "1", title: "First", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())
        let product2 = Product(id: "2", title: "Second", description: "Test", imageUrl: "", price: 20, stock: 1, postedBy: "Admin", createdAt: Date())

        let expectation = expectation(description: "Multiple products added")
        var updateCount = 0

        cartDataSource.cartItemsPublisher
            .sink { items in
                updateCount += 1
                if updateCount == 3 { // Initial empty + two adds
                    XCTAssertEqual(items.count, 2)
                    XCTAssertEqual(items[0].id, "1")
                    XCTAssertEqual(items[1].id, "2")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        cartDataSource.addToCart(product1)
        cartDataSource.addToCart(product2)

        wait(for: [expectation], timeout: 1.0)
    }
}
