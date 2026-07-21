//
//  CartItem.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 19.07.2026.
//

import Foundation

struct CartItem: Identifiable {
    let id: String
    let product: Product
    var quantity: Int

    init(product: Product, quantity: Int = 1) {
        self.id = product.id
        self.product = product
        self.quantity = quantity
    }
}
