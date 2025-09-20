//
//  SocialEcomAppApp.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI
import Firebase

@main
struct SocialEcomApp: App {
    let coordinator = AppCoordinator()
    
    init(){
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
