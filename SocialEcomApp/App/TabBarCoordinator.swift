//
//  TabBarCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import Foundation
import SwiftUI

final class TabBarCoordinator {
    func start() -> some View {
        TabView {
            ProductListCoordinator().start()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ChatCoordinator().start()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }

//            ProfileCoordinator().start()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("Profile")
//                }
        }
    }
}
