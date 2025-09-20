//
//  FirestoreProductService.swift
//  SocialEcomApp
//
//  Created by Krunal Mistry on 9/19/25.
//


import FirebaseFirestore

class FirestoreService: ProductServiceProtocol {
    private let db = Firestore.firestore()

    func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {

        db.collection("products")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    completion(.failure(error))
                } else {
                    do {
                        let products = try snapshot?.documents.compactMap {
                            try $0.data(as: Product.self)
                        }
                        completion(.success(products ?? []))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
}

extension FirestoreService: CommentServiceProtocol {

     func fetchComments(
         productId: String,
         completion: @escaping (Result<[Comment], Error>) -> Void
     ) {
         db.collection("comments")
             .whereField("productId", isEqualTo: productId)
             .order(by: "createdAt")
             .getDocuments { snapshot, error in
                 if let error = error {
                     completion(.failure(error))
                 } else {
                     do {
                         let comments = try snapshot?.documents.compactMap {
                             try $0.data(as: Comment.self)
                         }
                         completion(.success(comments ?? []))
                     } catch {
                         completion(.failure(error))
                     }
                 }
             }
     }

     func addComment(
         _ comment: Comment,
         completion: @escaping (Result<Void, Error>) -> Void
     ) {
         do {
             try db.collection("comments")
                 .document(comment.id)
                 .setData(from: comment, merge: true) { error in
                     if let error = error {
                         completion(.failure(error))
                     } else {
                         completion(.success(()))
                     }
                 }
         } catch {
             completion(.failure(error))
         }
     }}
