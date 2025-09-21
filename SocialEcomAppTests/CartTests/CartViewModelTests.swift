//
//  CartViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

final class CartViewModelTests: XCTestCase {
    
    private var viewModel: CartViewModel!
    private var mockDataSource: MockCartDataSource!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockDataSource = MockCartDataSource()
        viewModel = CartViewModel(dataSource: mockDataSource)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockDataSource = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialStateIsEmpty() {
        XCTAssertTrue(viewModel.cartItems.isEmpty, "Cart should be empty initially")
        XCTAssertEqual(viewModel.cartCount, 0, "Cart count should be zero initially")
    }
    
    func testAddToCartUpdatesViewModel() {
        let product = Product(id: "1", title: "Cart Product", description: "Test", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())
        
        let expectation1 = expectation(description: "Cart items updated")
        let expectation2 = expectation(description: "Cart count updated")
        
        viewModel.$cartItems
            .dropFirst()
            .sink { items in
                if items.count == 1 {
                    XCTAssertEqual(items.first?.title, "Cart Product")
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$cartCount
            .dropFirst()
            .sink { count in
                if count == 1 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Add via data source since ViewModel doesn't expose add method
        mockDataSource.addToCart(product)
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    func testRemoveFromCartUpdatesViewModel() {
        let product1 = Product(id: "1", title: "Product 1", description: "", imageUrl: "", price: 10, stock: 1, postedBy: "Admin", createdAt: Date())
        let product2 = Product(id: "2", title: "Product 2", description: "", imageUrl: "", price: 20, stock: 2, postedBy: "Admin", createdAt: Date())
        
        mockDataSource.addToCart(product1)
        mockDataSource.addToCart(product2)
        
        let expectation1 = expectation(description: "Cart items after removal updated")
        let expectation2 = expectation(description: "Cart count after removal updated")
        
        viewModel.$cartItems
            .dropFirst(3) // initial empty + product1 + product2
            .sink { items in
                if items.count == 1 && items.first?.id == "2" {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$cartCount
            .dropFirst(3)
            .sink { count in
                if count == 1 {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.removeFromCart(productId: "1")
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
}