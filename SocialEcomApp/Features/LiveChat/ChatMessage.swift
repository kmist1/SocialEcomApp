//
//  ChatMessage.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/20/25.
//


import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let text: String
    let sender: String
    let timestamp: Date
}
