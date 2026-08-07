//
//  FavoritesService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 05.08.2026.
//

import Foundation

@Observable
final class FavoritesService {
    private(set) var products: [Product] = []
    
    func isFavorite(_ product: Product) -> Bool {
        products.contains { $0.id == product.id}
    }
    
    func toggle( _ product: Product) {
        if isFavorite(product) {
            products.removeAll {$0.id == product.id}
        } else {
            products.append(product)
        }
    }
}
