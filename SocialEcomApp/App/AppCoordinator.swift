//
//  AppCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var rootView: AnyView = AnyView(EmptyView())

    private var tabBarCoordinator: TabBarCoordinator!

    init() {
        start()
    }

    func start() {
        tabBarCoordinator = TabBarCoordinator()
        rootView = AnyView(tabBarCoordinator.start())
    }
}
