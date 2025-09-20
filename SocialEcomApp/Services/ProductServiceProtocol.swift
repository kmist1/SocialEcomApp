//
//  ProductServiceProtocol.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/19/25.
//


protocol ProductServiceProtocol {
    func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void)
}
