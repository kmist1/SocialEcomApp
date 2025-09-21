# 📱 SocialEcomApp

## 🚀 Summary

SocialEcomApp is a social e-commerce iOS application built with SwiftUI using the **MVVM-C (Model–View–ViewModel–Coordinator) architecture**. It provides users with a comprehensive shopping experience by allowing them to:

*   Browse and filter products.
*   View product details, complete with integrated cart, comments, and chat functionalities.
*   Add items to their cart, with a dynamic badge reflecting the number of items.
*   Participate in real-time product chats via **Firebase**.
*   Comment on products and engage in threaded replies.

This project serves as a practical demonstration of modular design, coordinator-based navigation, and Firebase's real-time capabilities.

## 🎥 Working Video

> **👉 (To be added)** — A demo walkthrough video showcasing the app in action will be added here.

## 🏗 High-Level System Design

> ![System Design Diagram](/docs/SocialEcomApp_SystemDesign.png)

## 🔄 Low-Level Data Flow Diagram

> ![Data Flow Diagram](/docs/SocialEcomApp_DataFlow.png)

## ⚡ Sequence Diagrams

*   Add to Cart
*   Chat (Realtime Messaging)
*   Comments (Request–Response)

> ![Add to Cart Sequence Diagram](/docs/SocialEcomApp_AddToCart_Sequence.png)
> *(Insert other sequence diagram image links here, e.g., `/docs/SocialEcomApp_Chat_Sequence.png`)*

## 🛠 Tech Stack

*   **Language:** Swift 5.9+
*   **Frameworks:** SwiftUI, Combine.
*   **Architecture:** MVVM-C (Model–View–ViewModel–Coordinator).
*   **Backend:** Firebase Firestore (for the real-time database).
*   **Testing:** XCTest with mockable services facilitated by `ServiceFactory`.
*   **CI/CD:** Xcode build system (extendable with Fastlane/Jenkins).

## 🧩 Design Decisions

*   **MVVM-C** was chosen for its clear separation of concerns, providing a maintainable and testable codebase.
    *   **Views:** Handle the SwiftUI UI layer.
    *   **ViewModels:** Manage UI state and business logic.
    *   **DataSources:** Handle feature-specific data operations (e.g., pagination, caching).
    *   **Services:** Manage Firebase integrations behind protocol abstractions for testability.
    *   **Coordinators:** Orchestrate navigation flows throughout the app.
*   The **`ServiceFactory`** approach allows for easy swapping of real services with mock implementations during testing.
*   **Firestore listeners** are used to enable real-time updates for the chat and comments features.
*   **Protocol-oriented design** promotes dependency injection and simplifies the process of creating mocks.

## ▶️ How to Run the App

1.  **Clone this repository**:
    ```sh
    git clone https://github.com/your-repo/SocialEcomApp.git
    cd SocialEcomApp
    ```

2.  **Open in Xcode**:
    ```sh
    open SocialEcomApp.xcodeproj
    ```

3.  **Install dependencies**:
    *   Ensure you have CocoaPods or Swift Package Manager set up (if applicable).
    *   Add your `GoogleService-Info.plist` file (obtained from the Firebase Console) to the project's root.

4.  **Build & Run**:
    *   Select the `SocialEcomApp` scheme.
    *   Choose a simulator or physical device.
    *   Press the ▶ button in Xcode to build and run the app.

## 📄 PRD & Documentation

> **👉 (Confluence link here)**

*   Product Requirements Document (PRD)
*   UML Sequence Diagrams

## 📌 Future Enhancements

*   User authentication and profiles.
*   Functionality to save or favorite products.
*   Push notifications for new chat messages or replies.
*   Offline-first support with local caching.
*   Dark mode theming.
