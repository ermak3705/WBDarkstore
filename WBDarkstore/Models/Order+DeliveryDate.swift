//
//  Order+DeliveryDate.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 13.09.2026.
//

import Foundation

extension Order {
    private static let isoFormatterFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    var parsedDeliveryDate: Date? {
        guard let deliveryDate else { return nil }
        return Self.isoFormatterFractional.date(from: deliveryDate) ?? Self.isoFormatter.date(from: deliveryDate)
    }
}
