//
//  Category.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 04.07.2026.
//

import Foundation


struct Category: Identifiable {
    var id = UUID()
    var name: String
    var imageURL: URL?
}
