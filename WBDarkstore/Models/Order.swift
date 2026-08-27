//
//  Order.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 26.08.2026.
//

import Foundation

enum OrderStatus: String, Hashable {
    case active
    case completed
}

struct OrderItem: Identifiable, Hashable {
    var id: String
    var imageURL: URL?
    var title: String
    var weight: Int
    var price: Int
    var quantity: Int
}

struct Order: Identifiable, Hashable {
    var id: String
    var status: OrderStatus
    var deliveryDate: String?
    var addressLine: String
    var orderPrice: Int
    var deliveryPrice: Int
    var totalPrice: Int
    var totalItems: Int
    var items: [OrderItem]
}
