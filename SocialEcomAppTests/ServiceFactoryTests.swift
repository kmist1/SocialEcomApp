//
//  ServiceFactoryTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/21/25.
//
import XCTest
import Combine
@testable import SocialEcomApp

class ServiceFactoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset to default state
        ServiceFactory.backend = .firestore
    }
    
    func testMakeProductService_FirestoreBackend_ReturnsFirestoreService() {
        // Given
        ServiceFactory.backend = .firestore
        
        // When
        let service = ServiceFactory.makeProductService()
        
        // Then
        XCTAssertTrue(service is FirestoreService)
    }
    
    func testMakeProductService_RestBackend_ReturnsRestService() {
        // Given
        ServiceFactory.backend = .rest
        
        // When
        let service = ServiceFactory.makeProductService()
        
        // Then
        XCTAssertTrue(service is RestSubbService)
    }
    
    func testMakeCommentService_FirestoreBackend_ReturnsFirestoreService() {
        // Given
        ServiceFactory.backend = .firestore
        
        // When
        let service = ServiceFactory.makeCommentService()
        
        // Then
        XCTAssertTrue(service is FirestoreService)
    }
    
    func testMakeLiveChatService_FirestoreBackend_ReturnsFirestoreService() {
        // Given
        ServiceFactory.backend = .firestore
        
        // When
        let service = ServiceFactory.makeLiveChatService()
        
        // Then
        XCTAssertTrue(service is FirestoreService)
    }
}

class MockProductService: ProductServiceProtocol {
    var shouldReturnError = false
    var mockProducts: [Product] = []
    var fetchCallCount = 0

    func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        fetchCallCount += 1

        if shouldReturnError {
            completion(.failure(TestError.networkError))
        } else {
            completion(.success(mockProducts))
        }
    }
}
