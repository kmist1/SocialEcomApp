//
//  Comment.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//
import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let productId: String
    let userId: String
    let text: String
    let createdAt: Date
    var parentId: String? // nil → top-level comment, otherwise it's a reply
}
