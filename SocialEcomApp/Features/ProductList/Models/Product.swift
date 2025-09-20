//
//  Product.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//
import Foundation

struct Product: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var imageUrl: String
    var price: Double
    var stock: Int
    var postedBy: String
    var createdAt: Date
}
