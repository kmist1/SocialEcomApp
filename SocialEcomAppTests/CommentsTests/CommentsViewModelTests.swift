//
//  CommentsViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/21/25.
//
import XCTest
import Combine
@testable import SocialEcomApp

@MainActor
class CommentsViewModelTests: XCTestCase {
    var viewModel: CommentsViewModel!
    var mockDataSource: MockCommentsDataSource!
    
    override func setUp() {
        super.setUp()
        mockDataSource = MockCommentsDataSource()
        viewModel = CommentsViewModel(dataSource: mockDataSource)
    }
    
    override func tearDown() {
        viewModel = nil
        mockDataSource = nil
        super.tearDown()
    }
    
    func testLoadComments_Success_UpdatesStateToLoaded() async {
        // Given
        let productId = "product1"
        let mockComments = [
            Comment(id: "1", productId: productId, userId: "user1", text: "Great product!", createdAt: Date(), parentId: nil),
            Comment(id: "2", productId: productId, userId: "user2", text: "I agree!", createdAt: Date(), parentId: "1")
        ]
        mockDataSource.mockComments = mockComments
        
        // When
        viewModel.loadComments(for: productId)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockDataSource.loadCommentsCallCount, 1)
        
        if case .loaded(let comments) = viewModel.state {
            XCTAssertEqual(comments.count, 2)
            XCTAssertEqual(comments[0].text, "Great product!")
        } else {
            XCTFail("Expected loaded state")
        }
    }
    
    func testLoadComments_Failure_UpdatesStateToError() async {
        // Given
        let productId = "product1"
        mockDataSource.shouldReturnError = true
        
        // When
        viewModel.loadComments(for: productId)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        if case .error(let errorMessage) = viewModel.state {
            XCTAssertFalse(errorMessage.isEmpty)
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testAddComment_Success_UpdatesLocalState() async {
        // Given
        let productId = "product1"
        let existingComment = Comment(id: "1", productId: productId, userId: "user1", text: "Existing comment", createdAt: Date(), parentId: nil)
        mockDataSource.mockComments = [existingComment]
        viewModel.state = .loaded([existingComment])
        
        let newComment = Comment(id: "2", productId: productId, userId: "user2", text: "New comment", createdAt: Date(), parentId: nil)
        
        // When
        viewModel.addComment(newComment)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockDataSource.addCommentCallCount, 1)
        XCTAssertEqual(mockDataSource.addedComments.count, 1)
        XCTAssertEqual(mockDataSource.addedComments[0].text, "New comment")
        
        if case .loaded(let comments) = viewModel.state {
            XCTAssertEqual(comments.count, 2)
        } else {
            XCTFail("Expected loaded state with updated comments")
        }
    }
    
    func testGroupedComments_ReturnsCorrectStructure() {
        // Given
        let parentComment = Comment(id: "1", productId: "product1", userId: "user1", text: "Parent comment", createdAt: Date(), parentId: nil)
        let replyComment = Comment(id: "2", productId: "product1", userId: "user2", text: "Reply comment", createdAt: Date(), parentId: "1")
        let anotherParent = Comment(id: "3", productId: "product1", userId: "user3", text: "Another parent", createdAt: Date(), parentId: nil)
        
        viewModel.state = .loaded([parentComment, replyComment, anotherParent])
        
        // When
        let (topLevel, replies) = viewModel.groupedComments()
        
        // Then
        XCTAssertEqual(topLevel.count, 2)
        XCTAssertTrue(topLevel.contains(where: { $0.id == "1" }))
        XCTAssertTrue(topLevel.contains(where: { $0.id == "3" }))
        
        XCTAssertEqual(replies["1"]?.count, 1)
        XCTAssertEqual(replies["1"]?[0].text, "Reply comment")
    }
    
    func testGroupedComments_EmptyState_ReturnsEmpty() {
        // Given
        viewModel.state = .idle
        
        // When
        let (topLevel, replies) = viewModel.groupedComments()
        
        // Then
        XCTAssertTrue(topLevel.isEmpty)
        XCTAssertTrue(replies.isEmpty)
    }
}
