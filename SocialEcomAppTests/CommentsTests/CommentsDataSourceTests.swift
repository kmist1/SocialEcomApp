//
//  CommentsDataSourceTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import XCTest
import Combine
@testable import SocialEcomApp

final class CommentsDataSourceTests: XCTestCase {

    private var mockDataSource: MockCommentsDataSource!
    private var productId = "P123"
    private var sampleComment: Comment!

    override func setUp() {
        super.setUp()
        mockDataSource = MockCommentsDataSource()
        sampleComment = Comment(
            id: "1",
            productId: productId,
            userId: "User1",
            text: "Test comment",
            createdAt: Date(),
            parentId: nil
        )
        mockDataSource.mockComments = [sampleComment]
    }

    override func tearDown() {
        mockDataSource = nil
        sampleComment = nil
        super.tearDown()
    }

    func testLoadCommentsSuccess() {
        let expectation = expectation(description: "Comments loaded successfully")

        mockDataSource.loadComments(for: productId) { result in
            switch result {
            case .success(let comments):
                XCTAssertEqual(comments.count, 1)
                XCTAssertEqual(comments.first?.text, "Test comment")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testLoadCommentsFailure() {
        mockDataSource.shouldFail = true
        let expectation = expectation(description: "Comments load failed")

        mockDataSource.loadComments(for: productId) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testAddCommentSuccess() {
        let expectation = expectation(description: "Comment added successfully")

        let newComment = Comment(
            id: "2",
            productId: productId,
            userId: "User2",
            text: "Another comment",
            createdAt: Date(),
            parentId: nil
        )

        mockDataSource.addComment(newComment) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.mockDataSource.mockComments.count, 2)
                XCTAssertEqual(self.mockDataSource.mockComments.last?.text, "Another comment")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testAddCommentFailure() {
        mockDataSource.shouldFail = true
        let expectation = expectation(description: "Add comment failed")

        mockDataSource.addComment(sampleComment) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
