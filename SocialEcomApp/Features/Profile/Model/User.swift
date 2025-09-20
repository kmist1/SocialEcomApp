//
//  User.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let isAnonymous: Bool
    let joinedAt: Date
}
