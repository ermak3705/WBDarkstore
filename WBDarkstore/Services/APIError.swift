//
//  APIError.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.07.2026.
//

import Foundation

enum APIError: Error {
    case unauthorized
    case unexpected
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Сессия истекла. Пожалуйста, войдите снова."
        case .unexpected:
            return "Что-то пошло не так. Попробуйте ещё раз."
        }
    }
}
