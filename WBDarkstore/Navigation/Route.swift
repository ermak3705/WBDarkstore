//
//  Route.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation

enum Route: Hashable {
    case login
    case catalog
    case categoryDetail(Category)
    case profile
}
