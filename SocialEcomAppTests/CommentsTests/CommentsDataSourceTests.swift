//
//  CommentsDataSourceTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

class CommentsDataSourceTests: XCTestCase {
    var dataSource: CommentsDataSource!
    var mockService: MockCommentService!

    override func setUp() {
        super.setUp()
        mockService = MockCommentService()
        dataSource = CommentsDataSource(service: mockService)
    }

    override func tearDown() {
        dataSource = nil
        mockService = nil
        super.tearDown()
    }

    func testLoadComments_Success_ReturnsComments() {
        // Given
        let productId = "product1"
        let expectedComments = [
            Comment(id: "1", productId: productId, userId: "user1", text: "Great product!", createdAt: Date(), parentId: nil),
            Comment(id: "2", productId: productId, userId: "user2", text: "I agree!", createdAt: Date(), parentId: "1")
        ]
        mockService.mockComments = expectedComments

        let expectation = XCTestExpectation(description: "Comments loaded")

        // When
        dataSource.loadComments(for: productId) { result in
            // Then
            switch result {
            case .success(let comments):
                XCTAssertEqual(comments.count, 2)
                XCTAssertEqual(comments[0].productId, productId)
                XCTAssertEqual(comments[1].parentId, "1")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockService.fetchCallCount, 1)
    }

    func testAddComment_Success_AddsComment() {
        // Given
        let comment = Comment(id: "1", productId: "product1", userId: "user1", text: "New comment", createdAt: Date(), parentId: nil)

        let expectation = XCTestExpectation(description: "Comment added")

        // When
        dataSource.addComment(comment) { result in
            // Then
            switch result {
            case .success:
                XCTAssertEqual(self.mockService.addedComments.count, 1)
                XCTAssertEqual(self.mockService.addedComments[0].id, "1")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockService.addCallCount, 1)
    }

    func testAddComment_Failure_ReturnsError() {
        // Given
        let comment = Comment(id: "1", productId: "product1", userId: "user1", text: "New comment", createdAt: Date(), parentId: nil)
        mockService.shouldReturnError = true

        let expectation = XCTestExpectation(description: "Error handled")

        // When
        dataSource.addComment(comment) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertTrue(error is TestError)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

class MockCommentService: CommentServiceProtocol {
    var shouldReturnError = false
    var mockComments: [Comment] = []
    var addedComments: [Comment] = []
    var fetchCallCount = 0
    var addCallCount = 0

    func fetchComments(productId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        fetchCallCount += 1

        if shouldReturnError {
            completion(.failure(TestError.networkError))
        } else {
            let filteredComments = mockComments.filter { $0.productId == productId }
            completion(.success(filteredComments))
        }
    }

    func addComment(_ comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        addCallCount += 1

        if shouldReturnError {
            completion(.failure(TestError.networkError))
        } else {
            addedComments.append(comment)
            mockComments.append(comment)
            completion(.success(()))
        }
    }
}

