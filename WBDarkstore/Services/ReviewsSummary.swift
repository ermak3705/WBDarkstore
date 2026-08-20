//
//  ReviewsSummary.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 12.08.2026.
//

import Foundation

struct ReviewsSummary {
    let reviews: [Review]
    
    var averageRating: Double {
        guard !reviews.isEmpty else {return 0 }
        let sum = reviews.reduce(0) { $0 + $1.rating}
        return Double(sum) / Double(reviews.count)
    }
    
    var totalCount: Int {
        reviews.count
    }
    
    func count(for stars: Int) -> Int {
        (reviews.filter {$0.rating == stars}.count)
    }
    
    func percentage(for stars: Int) -> Double {
        guard totalCount > 0 else {return 0}
        return Double(count(for: stars)) / Double(totalCount)
    }
}
