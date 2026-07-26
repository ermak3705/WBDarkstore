//
//  CartService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 19.07.2026.
//

import Foundation

@Observable
final class CartService {
    private(set) var items: [CartItem] = []

    var totalPrice: Int {
        items.reduce(0) { $0 + $1.product.price * $1.quantity }
    }

    var totalCount: Int { 
        items.reduce(0) { $0 + $1.quantity }
    }

    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product))
        }
    }

    func increment(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].quantity += 1
    }

    func decrement(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }
}
