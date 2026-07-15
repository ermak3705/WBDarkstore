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
        //print("PUSH: \(route), path count: \(path.count)")
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
        //print("POP, path count: \(path.count)")
    }

    func popToRoot() {
        path.removeLast(path.count)
        //print("POP TO ROOT, path count: \(path.count)")
    }

    func replace(with route: Route) {
        popToRoot()
        push(route)
    }
}
