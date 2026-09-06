//
//  Address.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.08.2026.
//

import Foundation

struct Address: Identifiable, Hashable {
    var id: String
    var addressLine: String
    var coordinates: [Double]
    var floor: String?
    var entrance: String?
    var intercomCode: String?
    var comment: String?
}
