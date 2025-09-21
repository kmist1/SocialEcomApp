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
    
    private var mockCartDataSource: MockCartDataSource!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockCartDataSource = MockCartDataSource()
        cancellables = []
    }
    
    override func tearDown() {
        mockCartDataSource = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testAddToCartUpdatesItemsAndCount() {
        let product = Product(id: "1", title: "Cart Product", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())
        
        let expectation1 = expectation(description: "Cart items updated")
        let expectation2 = expectation(description: "Cart count updated")
        
        mockCartDataSource.cartItemsPublisher
            .dropFirst()
            .sink { items in
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items.first?.title, "Cart Product")
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        mockCartDataSource.cartCountPublisher
            .dropFirst()
            .sink { count in
                XCTAssertEqual(count, 1)
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        mockCartDataSource.addToCart(product)
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    func testInitialCartIsEmpty() {
        let items = mockCartDataSource.cartItems
        XCTAssertTrue(items.isEmpty, "Cart should be empty initially")
        XCTAssertEqual(mockCartDataSource.cartCount, 0)
    }
}
