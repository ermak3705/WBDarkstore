//
//  Product.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//

import Foundation
import SwiftUI

struct Product: Identifiable {
    var id = UUID()
    var title: String
    var price: Int
    var imageURL: URL?
}
