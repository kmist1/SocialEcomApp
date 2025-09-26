# 📱 SocialEcomApp

## Ask

- Product listing with filtering/search capability
- Product detail view with add-to-cart functionality
- Product sharing via the system share sheet
- Peer-to-peer commenting system on product pages
- Real-time updates when new comments are added
- Use Firebase or a mock backend for products, chat, and comments
- Show proper handling of real-time communications
- Use your discretion in UX design.


## 🚀 Summary

SocialEcomApp is a social e-commerce iOS application built with SwiftUI using the **MVVM-C (Model–View–ViewModel–Coordinator) architecture**. This project serves as a practical demonstration of modular design, coordinator-based navigation, and Firebase's real-time capabilities.

## Key Features

- Product Browsing: List view with filtering, search, and pagination
- Shopping Cart: Add/remove products with real-time count updates
- Product Details: Rich detail view with sharing capabilities
- Social Features: Comments system and live chat functionality
- Backend Flexibility: ServiceFactory pattern supporting Firestore and REST

## My thoughts and assumptions 
 - App will reach billions of users - Need to be scalable and maintainable. - In scope
 - Pagination for ProductList - In scope
 - Pagination for chat and comments, and cleanup: Chat and comments need pagination + retention policy to avoid memory bloat. - not in scope
 - Image caching: Catalog performance depends on optimized image loading and caching. - In scope 
 - Offline-first core flows: Browsing and cart must work without network; sync later.- In scope
 - User auth evolution: Start with anonymous users, but plan migration to social logins and Apple Sign-In. - In Scope
 - Rest API can be integrated. 

## ✅ MVP and 🚫 Out of MVP

### ✅ In Scope (MVP)
- **Architecture:** MVVM-C + DataSource pattern, ServiceFactory for backend flexibility.  
- **Realtime:** Firestore listeners for chat & comments, optimistic UI updates.  
- **Memory & Errors:** ViewModel cleanup, basic error handling & retry.  
- **UX:** Anonymous users, threaded comments (1-level), per-product chat rooms.  
- **Cart:** Offline-first support via local DataSource.  
- **Performance:** Efficient product queries, AsyncImage with loading states, reactive UI with Combine.  

### 🚫 Out of Scope (Future Versions)
- **Scale/Ops:** Chat retention policies, Firestore cost optimization, performance monitoring.  
- **Moderation:** Spam prevention, reporting & blocking, API rate limiting.  
- **Recommendations:** AI/ML-driven suggestions, trending/seasonal highlights.  
- **Advanced Chat:** Reactions, typing indicators, multimedia messages, chat profiles, push notifications.  
- **User Features:** Auth & profiles, social logins (e.g., Apple Sign-In, Facebook).  
- **Tech Enhancements:** Accessibility compliance and advanced caching strategies.  

---

## 🚀 Challenges & Solutions

1. **Real-time Data Sync (Chat & Comments)**  
   - *Challenge:* Keeping UI consistent with Firestore listeners across multiple screens.  
   - *Solution:* Used `@Published` in ViewModels + Combine pipelines to auto-propagate updates.  

2. **Complex Navigation (Product → Detail → Chat/Comments/Cart)**  
   - *Challenge:* Avoiding view-driven navigation logic.  
   - *Solution:* Adopted **Coordinator pattern (MVVM-C)** to centralize flows and keep Views lightweight.  

3. **Testability with Firebase Dependencies**  
   - *Challenge:* Direct Firestore calls made unit testing difficult.  
   - *Solution:* Introduced **protocol-backed Services + ServiceFactory** to inject mocks for testing.  

4. **SwiftUI Limitation**  
   - *Challenge:* SwiftUI doesn’t provide a native ShareSheet.  
   - *Solution:* Implemented **UIViewControllerRepresentable** to integrate UIKit ShareSheet with SwiftUI.  

## ⚖️ Tradeoff Matrix

| **Decision**                   | **Chosen**                            | **Tradeoff**                                              | **Alternative**                          |
|--------------------------------|----------------------------------------|-----------------------------------------------------------|------------------------------------------|
| Architecture vs Speed           | MVVM-C + DI + Coordinators             | Slower initial dev, more complexity                       | MVC for faster shipping, more tech debt  |
| Backend                         | Firebase Firestore                     | Vendor lock-in, scaling costs                             | Custom REST backend, more dev effort     |
| Filtering                       | Client-side (search, price)            | Fine for small sets, doesn’t scale                        | Server-side filtering for large datasets |
| Cart                            | Local/in-memory                        | Resets on restart, no persistence                         | Persistent cart with backend + auth      |
| Auth                            | Anonymous users                        | No profiles, history, or sync                             | Full auth + Apple Sign-In                | 
| Comments                        | One-level parent/child threads         | Simple but limited discussion depth                       | Nested threads (Reddit-style)            |
| Real-time Updates               | Chat only                              | Balanced UX vs Firestore costs                            | Full realtime for all features           |
| UI Framework                    | SwiftUI                                | iOS 14+ only, some quirks                                 | UIKit for wider support, more boiler     |
| Offline Mode                    | Hybrid (offline cart, online social)   | More complex state management                             | Online-only, simpler but brittle offline |

## Architecture Overview
App follows a Coordinator Pattern with MVVM architecture, which is excellent for maintainability and testability:

 - AppCoordinator → TabBarCoordinator → Individual feature coordinators
 - Clear separation of concerns with ViewModels, DataSources, and Services
 - Protocol-oriented design for services (Firebase/REST flexibility)

## 🎥 Working Video
![Simulator Screen Recording - iPhone 16 - 2025-09-21 at 18 24 45](https://github.com/user-attachments/assets/5fd4309b-d0b5-4c98-b2d3-d91a1834cfb8)



## 🏗 High-Level System Design
<img width="3840" height="1947" alt="new highlevel ecomm diagram " src="https://github.com/user-attachments/assets/051ee9be-70d5-4ff4-8f13-227785601848" />
Class Level:
<img width="3840" height="1592" alt="HighLevelEcommDiagram" src="https://github.com/user-attachments/assets/30a45629-ce8c-45a1-b0b1-9122f42105a2" />

> High-Level System Design: (https://www.mermaidchart.com/app/projects/36be8ae2-7e2e-482e-822a-675eb34bb6d6/diagrams/725b50ec-6b94-4d1b-b99c-807305529643/version/v0.1/edit)

## ⚡ Sequence Diagrams

<img width="1143" height="3839" alt="HighLevelSequence-EcommApp" src="https://github.com/user-attachments/assets/66c4aa48-c8ec-42dd-930e-66516d65e3bd" />

> High-Level Sequence Diagram: (https://www.mermaidchart.com/app/projects/36be8ae2-7e2e-482e-822a-675eb34bb6d6/diagrams/eab7c5fd-5670-453b-9b5f-12f5b52ddb07/version/v0.1/edit)

## Firestore database entity relationship diagram

<img width="3513" height="258" alt="SocialEcomApp_ERDiagram" src="https://github.com/user-attachments/assets/b8212976-802b-4d3d-91f8-2be0deb9ea8b" />

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

## 📄 Unit Tests 
- Currently covering Service layer, Datasources, and ViewModels. Need to add tests for UI views.


<img width="1715" height="993" alt="Screenshot 2025-09-21 at 6 18 44 PM" src="https://github.com/user-attachments/assets/f8754cfe-0a68-4a5e-a8d6-7774615b642c" />



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
