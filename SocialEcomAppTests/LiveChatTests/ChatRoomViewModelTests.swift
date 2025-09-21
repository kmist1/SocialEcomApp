//
//  ChatRoomViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/21/25.
//


import XCTest
@testable import SocialEcomApp

final class ChatRoomViewModelTests: XCTestCase {

    func test_initialState() {
        let vm = ChatRoomViewModel(productId: "123", productTitle: "Test", service: MockChatService())
        XCTAssertTrue(vm.messages.isEmpty)
        XCTAssertEqual(vm.productTitle, "Test")
    }

    func test_sendMessage_appendsToMockService() {
        let mockService = MockChatService()
        let vm = ChatRoomViewModel(productId: "123", productTitle: "Test", service: mockService)

        vm.newMessage = "Hello World"
        vm.sendMessage()

        XCTAssertTrue(mockService.sentMessages.count == 1)
        XCTAssertEqual(mockService.sentMessages.first?.text, "Hello World")
        XCTAssertEqual(vm.newMessage, "", "Message input should reset after send")
    }

    func test_sendMessage_doesNothingWhenEmpty() {
        let mockService = MockChatService()
        let vm = ChatRoomViewModel(productId: "123", productTitle: "Test", service: mockService)

        vm.newMessage = ""
        vm.sendMessage()

        XCTAssertTrue(mockService.sentMessages.isEmpty)
    }

    func test_sendMessage_handlesFailure() {
        let mockService = MockChatService()
        mockService.shouldFail = true
        let vm = ChatRoomViewModel(productId: "123", productTitle: "Test", service: mockService)

        vm.newMessage = "Fail this"
        vm.sendMessage()

        XCTAssertTrue(mockService.sentMessages.isEmpty, "Should not persist on failure")
    }
}

class MockChatService: ChatServiceProtocol {
    var sentMessages: [ChatMessage] = []
    var shouldFail = false

    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "MockError", code: -1)))
        } else {
            sentMessages.append(message)
            completion(.success(()))
        }
    }
}
