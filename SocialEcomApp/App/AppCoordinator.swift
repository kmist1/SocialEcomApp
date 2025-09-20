//
//  AppCoordinator.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//

import SwiftUI

final class AppCoordinator {
    func start() -> some View {
        ProductListCoordinator().start()
    }
}
