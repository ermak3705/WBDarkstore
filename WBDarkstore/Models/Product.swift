//
//  Product.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//

import Foundation
import SwiftUI

struct Product: Identifiable, Hashable {
    var id: String
    var title: String
    var price: Int
    var imageURL: URL?
    var rating: Double
    var reviewCount: Int
    var weight: Int 
}
