//
//  Router.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation
import SwiftUI

@Observable
final class Router {
    var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func replace(with route: Route) {
        popToRoot()
        push(route)
    }
}
