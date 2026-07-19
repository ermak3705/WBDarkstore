//
//  WBDarkstoreApp.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 28.06.2026.
//

import SwiftUI

@main
struct WBDarkstoreApp: App {

    let productsService: ProductsService

    init() {
       
        KeychainHelper.save(Secrets.apiToken, forKey: "apiToken")

        guard let token = KeychainHelper.read(forKey: "apiToken") else {
            fatalError("Токен не найден в Keychain")
        }

        let client = try! APIClientFactory.makeClient(token: token)
        productsService = ProductsService(client: client)
    }

    var body: some Scene {
        WindowGroup {
            CatalogView(service: productsService)
        }
    }
}
