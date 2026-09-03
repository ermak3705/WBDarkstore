//
//  Int+Pluralization.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.09.2026.
//

import Foundation

extension Int {

    func pluralized(one: String, few: String, many: String) -> String {
        let mod10 = self % 10
        let mod100 = self % 100

        if (11...14).contains(mod100) {
            return many
        }

        switch mod10 {
        case 1:
            return one
        case 2, 3, 4:
            return few
        default:
            return many
        }
    }
}
