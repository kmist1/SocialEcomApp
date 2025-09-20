//
//  ProductDataSourceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/18/25.
//


import Foundation
import Combine

protocol ProductDataSourceProtocol {
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    func loadInitial()
    func loadMoreIfNeeded(currentItem: Product?)
}