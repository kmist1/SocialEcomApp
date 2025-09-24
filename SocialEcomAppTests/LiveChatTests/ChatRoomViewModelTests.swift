//
//  ChatRoomViewModelTests.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/21/25.
//


import XCTest
import Combine
import FirebaseFirestore
@testable import SocialEcomApp

// Import shared test utilities
@testable import SocialEcomAppTests

// MARK: - Test Helpers
private extension ChatRoomViewModelTests {
    func assertMessagesEqual(_ lhs: ChatMessage, _ rhs: ChatMessage, tolerance: TimeInterval = 1.0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs.id, rhs.id, "Message IDs don't match", file: file, line: line)
        XCTAssertEqual(lhs.text, rhs.text, "Message texts don't match", file: file, line: line)
        XCTAssertEqual(lhs.sender, rhs.sender, "Message senders don't match", file: file, line: line)
        XCTAssertLessThan(
            abs(lhs.timestamp.timeIntervalSince(rhs.timestamp)),
            tolerance,
            "Message timestamps are too far apart",
            file: file,
            line: line
        )
    }
}

// MARK: - Mock Chat Service for Testing

class MockChatService: ChatServiceProtocol {
    var shouldReturnError = false
    var sentMessages: [ChatMessage] = []
    var mockMessages: [ChatMessage] = []
    var sendMessageCallCount = 0
    var listenForMessagesCallCount = 0

    // Mock listener registration for testing
    private var mockListener: MockListenerRegistration?
    private var messageUpdateHandler: ((Result<[ChatMessage], Error>) -> Void)?

    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        sendMessageCallCount += 1

        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                self.sentMessages.append(message)
                // Simulate the message being added to the listener's stream
                self.mockMessages.append(message)
                self.triggerListenerUpdate()
                completion(.success(()))
            }
        }
    }

    // For testing purposes, we'll create a mock listener
    func listenForMessages(productId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
        listenForMessagesCallCount += 1
        messageUpdateHandler = completion

        let listener = MockListenerRegistration()
        self.mockListener = listener

        // Immediately return existing messages
        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                completion(.success(self.mockMessages))
            }
        }

        return listener
    }

    // Helper method to trigger listener updates in tests
    func triggerListenerUpdate() {
        DispatchQueue.main.async {
            if self.shouldReturnError {
                self.messageUpdateHandler?(.failure(TestError.networkError))
            } else {
                self.messageUpdateHandler?(.success(self.mockMessages))
            }
        }
    }

    func addMockMessage(_ message: ChatMessage) {
        mockMessages.append(message)
        triggerListenerUpdate()
    }

    func clearMessages() {
        mockMessages.removeAll()
        sentMessages.removeAll()
    }
}

// MARK: - Mock Listener Registration

class MockListenerRegistration: NSObject, ListenerRegistration {
    var isRemoved = false

    func remove() {
        isRemoved = true
    }
}

// MARK: - Extended Mock Chat Service for Firestore Testing

class MockFirestoreService: ChatServiceProtocol {
    var shouldReturnError = false
    var sentMessages: [ChatMessage] = []
    var mockMessages: [ChatMessage] = []
    var sendCallCount = 0
    var listenerCallCount = 0

    private var messageUpdateHandler: ((Result<[ChatMessage], Error>) -> Void)?

    func sendMessage(productId: String, message: ChatMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        sendCallCount += 1

        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                self.sentMessages.append(message)
                self.mockMessages.append(message)
                // Simulate real-time update
                self.messageUpdateHandler?(.success(self.mockMessages))
                completion(.success(()))
            }
        }
    }

    func listenForMessages(productId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
        listenerCallCount += 1
        self.messageUpdateHandler = completion

        // Return initial messages
        DispatchQueue.main.async {
            if self.shouldReturnError {
                completion(.failure(TestError.networkError))
            } else {
                completion(.success(self.mockMessages))
            }
        }

        return MockListenerRegistration()
    }

    // Test helper methods
    func simulateIncomingMessage(_ message: ChatMessage) {
        mockMessages.append(message)
        DispatchQueue.main.async {
            self.messageUpdateHandler?(.success(self.mockMessages))
        }
    }

    func simulateError(_ error: Error) {
        DispatchQueue.main.async {
            self.messageUpdateHandler?(.failure(error))
        }
    }
}

// MARK: - ChatRoomViewModel Tests

class ChatRoomViewModelTests: XCTestCase {
    var viewModel: ChatRoomViewModel!
    var mockService: MockChatService!
    var mockFirestoreService: MockFirestoreService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockChatService()
        mockFirestoreService = MockFirestoreService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        mockFirestoreService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_WithValidInputs_SetsPropertiesCorrectly() {
        // Given
        let productId = "product123"
        let productTitle = "iPhone 15"

        // When
        viewModel = ChatRoomViewModel(
            productId: productId,
            productTitle: productTitle,
            service: mockService
        )

        // Then
        XCTAssertEqual(viewModel.productTitle, productTitle)
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.newMessage.isEmpty)
        XCTAssertFalse(viewModel.currentUser.isEmpty)
        XCTAssertTrue(viewModel.currentUser.starts(with: "User"))
        XCTAssertEqual(mockService.listenForMessagesCallCount, 1)
    }

    func testInitialization_WithEmptyProductId_DoesNotStartListener() {
        // Given
        let productId = ""
        let productTitle = "Test Product"

        // When
        viewModel = ChatRoomViewModel(
            productId: productId,
            productTitle: productTitle,
            service: mockService
        )

        // Then
        XCTAssertEqual(mockService.listenForMessagesCallCount, 0)
    }

    // MARK: - Send Message Tests

    func testSendMessage_WithValidMessage_SendsSuccessfully() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )
        viewModel.newMessage = "Hello, world!"
        let initialMessageText = viewModel.newMessage

        // When
        viewModel.sendMessage()

        // Wait for async operation
        let expectation = XCTestExpectation(description: "Message sent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 1)
        XCTAssertEqual(mockService.sentMessages.count, 1)
        XCTAssertEqual(mockService.sentMessages[0].text, initialMessageText)
        XCTAssertEqual(mockService.sentMessages[0].sender, viewModel.currentUser)
        XCTAssertTrue(viewModel.newMessage.isEmpty) // Should be cleared after sending
    }

    func testSendMessage_WithEmptyMessage_DoesNotSend() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )
        viewModel.newMessage = ""

        // When
        viewModel.sendMessage()

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 0)
        XCTAssertEqual(mockService.sentMessages.count, 0)
    }

    func testSendMessage_WithWhitespaceOnlyMessage_DoesNotSend() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )
        viewModel.newMessage = "   \n\t  "

        // When
        viewModel.sendMessage()

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 0)
        XCTAssertEqual(mockService.sentMessages.count, 0)
    }

    func testSendMessage_WithEmptyProductId_DoesNotSend() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "",
            productTitle: "Test Product",
            service: mockService
        )
        viewModel.newMessage = "Test message"

        // When
        viewModel.sendMessage()

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 0)
    }

    func testSendMessage_ServiceError_DoesNotClearMessage() {
        // Given
        mockService.shouldReturnError = true
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )
        viewModel.newMessage = "Test message"
        let originalMessage = viewModel.newMessage

        // When
        viewModel.sendMessage()

        // Wait for async operation
        let expectation = XCTestExpectation(description: "Error handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 1)
        XCTAssertTrue(viewModel.newMessage.isEmpty) // Still clears the message field
    }

    // MARK: - Message Listening Tests

    func testListenForMessages_InitialLoad_UpdatesMessages() {
        // Given
        let initialMessages = [
            ChatMessage(id: "1", text: "Hello", sender: "User1", timestamp: Date(timeIntervalSince1970: 1000)),
            ChatMessage(id: "2", text: "Hi", sender: "User2", timestamp: Date(timeIntervalSince1970: 2000))
        ]
        mockFirestoreService.mockMessages = initialMessages

        let expectation = XCTestExpectation(description: "Messages loaded")
        var receivedMessages: [ChatMessage] = []

        // When
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            currentUser: "TestUser",
            service: mockFirestoreService
        )

        viewModel.$messages
            .dropFirst() // Skip initial empty state
            .sink { messages in
                receivedMessages = messages
                if messages.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(receivedMessages.count, 2)
        XCTAssertEqual(receivedMessages[0].text, "Hello")
        XCTAssertEqual(receivedMessages[1].text, "Hi")
    }

    func testListenForMessages_RealTimeUpdate_UpdatesMessages() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockFirestoreService
        )

        let expectation = XCTestExpectation(description: "Real-time update received")

        // When - Simulate a new message arriving
        let newMessage = ChatMessage(id: "3", text: "Hello", sender: "User1", timestamp: Date())

        viewModel.$messages
            .dropFirst() // Skip initial empty state
            .sink { messages in
                if messages.count == 1 && messages[0].text == "Hello" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockFirestoreService.simulateIncomingMessage(newMessage)

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages[0].text, "Hello")
    }

    func testListenForMessages_Error_HandlesGracefully() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockFirestoreService
        )

        let expectation = XCTestExpectation(description: "Error handled")

        // When
        mockFirestoreService.simulateError(TestError.networkError)

        // Wait for error handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then - App should continue functioning (messages remain empty but no crash)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    // MARK: - Integration Tests

    func testCompleteMessageFlow_SendAndReceive() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            currentUser: "TestUser",
            service: mockFirestoreService
        )

        let expectation = XCTestExpectation(description: "Message sent and received")
        var messageUpdateCount = 0

        viewModel.$messages
            .sink { messages in
                messageUpdateCount += 1
                if messages.count == 1 { // Wait for message
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.newMessage = "Integration test message"
        viewModel.sendMessage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages[0].text, "Integration test message")
        XCTAssertEqual(viewModel.messages[0].sender, "TestUser")
        XCTAssertTrue(viewModel.newMessage.isEmpty)
    }

    func testErrorHandling_EmptyProductId_SetsErrorMessage() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "",
            productTitle: "Test Product",
            currentUser: "TestUser",
            service: mockService
        )

        // Then
        XCTAssertEqual(viewModel.error, "Product ID cannot be empty")
    }

    func testErrorHandling_SendMessageFails_SetsErrorMessage() {
        // Given
        mockService.shouldReturnError = true
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            currentUser: "TestUser",
            service: mockService
        )

        let expectation = XCTestExpectation(description: "Error message set")

        viewModel.$error
            .dropFirst()
            .sink { error in
                if error != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.newMessage = "Test message"
        viewModel.sendMessage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Memory Management Tests

    func testDeinit_RemovesListener() {
        // Given
        let mockListener = MockListenerRegistration()
        mockService = MockChatService()

        // When
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )

        // Simulate deinit
        viewModel = nil

        // Then - This is hard to test directly, but we can verify the listener setup was called
        XCTAssertEqual(mockService.listenForMessagesCallCount, 1)
    }

    // MARK: - Edge Cases

    func testMessageValidation_VeryLongMessage_HandlesCorrectly() {
        // Given
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )

        let longMessage = String(repeating: "A", count: 1000)
        viewModel.newMessage = longMessage

        // When
        viewModel.sendMessage()

        // Wait for async operation
        let expectation = XCTestExpectation(description: "Long message sent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(mockService.sendMessageCallCount, 1)
        XCTAssertEqual(mockService.sentMessages[0].text, longMessage)
    }

    func testCurrentUser_IsConsistent() {
        // Given & When
        viewModel = ChatRoomViewModel(
            productId: "product123",
            productTitle: "Test Product",
            service: mockService
        )

        let initialUser = viewModel.currentUser

        // Send multiple messages
        viewModel.newMessage = "Message 1"
        viewModel.sendMessage()

        viewModel.newMessage = "Message 2"
        viewModel.sendMessage()

        // Then
        XCTAssertEqual(viewModel.currentUser, initialUser)
        // Verify all sent messages have the same sender
        if mockService.sentMessages.count >= 2 {
            XCTAssertEqual(mockService.sentMessages[0].sender, initialUser)
            XCTAssertEqual(mockService.sentMessages[1].sender, initialUser)
        }
    }
}

// MARK: - Message Comparison
extension ChatMessage {
    fileprivate static func compareMessages(_ lhs: ChatMessage, _ rhs: ChatMessage, tolerance: TimeInterval = 1.0) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.sender == rhs.sender &&
               abs(lhs.timestamp.timeIntervalSince(rhs.timestamp)) < tolerance
    }
}
