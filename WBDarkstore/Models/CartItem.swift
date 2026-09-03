//
//  CartItem.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 19.07.2026.
//

import Foundation

struct CartItem: Identifiable {
    let id: String
    var title: String
    var price: Int
    var imageURL: URL?
    var quantity: Int
}
