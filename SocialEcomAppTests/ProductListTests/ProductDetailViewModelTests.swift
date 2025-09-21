//
//  ProductDetailViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//
import XCTest
import Combine
@testable import SocialEcomApp

final class ProductDetailViewModelTests: XCTestCase {
    private var viewModel: ProductDetailViewModel!
    private var mockCartDataSource: MockCartDataSourceForDetail!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCartDataSource = MockCartDataSourceForDetail()
        let product = Product(
            id: "1",
            title: "Test Product",
            description: "Desc",
            imageUrl: "",
            price: 10,
            stock: 1,
            postedBy: "Admin",
            createdAt: Date()
        )
        viewModel = ProductDetailViewModel(product: product, cartDataSource: mockCartDataSource)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockCartDataSource = nil
        cancellables = nil
        super.tearDown()
    }

    func testAddToCartUpdatesIsAddedToCart() {
        XCTAssertFalse(viewModel.isAddedToCart, "Initially should be false")

        let expectation = expectation(description: "Product added to cart")

        viewModel.$isAddedToCart
            .first { $0 == true }  // ✅ Only trigger once when it becomes true
            .sink { isAdded in
                XCTAssertTrue(isAdded, "Should be true after adding to cart")
                XCTAssertEqual(self.mockCartDataSource.cartItems.count, 1, "Cart should have 1 product")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.addToCart()
        wait(for: [expectation], timeout: 1.0)
    }
}
