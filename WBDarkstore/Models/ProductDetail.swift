//
//  ProductDetail.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 21.07.2026.
//

import Foundation

struct ProductDetail: Identifiable {
    var id: String
    var title: String
    var description: String
    var price: Int
    var imageURL: URL?
}
