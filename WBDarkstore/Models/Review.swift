//
//  Review.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 10.08.2026.
//

import Foundation

struct Review: Identifiable {
    let id = UUID()
    var rating: Int
    var author: String
    var createdAt: Date
    var content: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: createdAt)
    }
}
