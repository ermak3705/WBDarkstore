//
//  CachedCartItem.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 26.08.2026.
//

import Foundation
import SwiftData

@Model
final class CachedCartItem {
    @Attribute(.unique) var id: String
    var title: String
    var price: Int
    var weight = 0 
    var imageURLString: String?
    var quantity: Int
    var sortOrder: Int

    init(
        id: String,
        title: String,
        price: Int,
        weight: Int,
        imageURLString: String?,
        quantity: Int,
        sortOrder: Int
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.weight = weight
        self.imageURLString = imageURLString
        self.quantity = quantity
        self.sortOrder = sortOrder
    }
}
