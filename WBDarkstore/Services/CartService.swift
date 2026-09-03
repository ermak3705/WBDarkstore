//
//  CartService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 19.07.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class CartService {
    private let store: CartActor

    private(set) var items: [CartItem] = []
    private(set) var isLoading = false
    var error: Error?

    var totalPrice: Int {
        items.reduce(0) { $0 + $1.price * $1.quantity }
    }

    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    init(client: Client) {
        self.store = CartActor(client: client)
        Task {
            await store.restoreFromCache()
            items = await store.items
        }
    }

    func loadCart() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            items = try await store.loadCart()
        } catch {
            self.error = error
        }
    }

    func add(_ product: Product) async {
        do {
            try await store.add(product)
            items = await store.items
        } catch {
            self.error = error
        }
    }

    func increment(_ item: CartItem) async {
        do {
            try await store.increment(item)
            items = await store.items
        } catch {
            self.error = error
        }
    }

    func decrement(_ item: CartItem) async {
        await remove(item)
    }

    func remove(_ item: CartItem) async {
        do {
            try await store.remove(item)
            items = await store.items
        } catch {
            self.error = error
        }
    }
}
