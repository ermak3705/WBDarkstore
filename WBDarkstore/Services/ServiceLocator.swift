//
//  ServiceLocator.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class ServiceLocator {
    
    let router: Router
    let authService: AuthService
    let userService: UserService
    let categoryService: CategoriesService
    let productService: ProductsService
    let cartService: CartService
    
    init() {
        let client = try! APIClientFactory.makeClient(token: Secrets.apiToken)
        
        self.router = Router()
        self.authService = AuthService()
        self.userService = UserService(client: client)
        self.categoryService = CategoriesService(client: client)
        self.productService = ProductsService(client: client)
        self.cartService = CartService()
    }
}
