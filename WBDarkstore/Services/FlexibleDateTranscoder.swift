//
//  FlexibleDateTranscoder.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.08.2026.
//

import Foundation
import OpenAPIRuntime

struct FlexibleISO8601DateTranscoder: DateTranscoder {
    private let formatterWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let formatterPlain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    func encode(_ date: Date) throws -> String {
        formatterWithFraction.string(from: date)
    }

    func decode(_ dateString: String) throws -> Date {
        if let date = formatterWithFraction.date(from: dateString) {
            return date
        }

        if let date = formatterPlain.date(from: dateString) {
            return date
        }

        if let range = dateString.range(of: #"\.\d+"#, options: .regularExpression) {
            let fraction = dateString[range].dropFirst()
            let truncated = fraction.prefix(3)
            let fixedString = dateString.replacingCharacters(in: range, with: ".\(truncated)")
            if let date = formatterWithFraction.date(from: fixedString) {
                return date
            }
        }

        throw DateParsingError.invalidFormat(dateString)
    }
}

enum DateParsingError: Error {
    case invalidFormat(String)
}
    
