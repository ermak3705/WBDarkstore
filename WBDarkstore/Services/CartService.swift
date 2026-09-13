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
    private(set) var error: Error?

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
        let previousItems = items
        
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index] = CartItem(
                id: items[index].id,
                title: items[index].title,
                price: items[index].price,
                weight: items[index].weight,
                imageURL: items[index].imageURL,
                quantity: items[index].quantity + 1
            )
        } else {
            items.append(
                CartItem(
                    id: product.id,
                    title: product.title,
                    price: product.price,
                    weight: product.weight,
                    imageURL: product.imageURL,
                    quantity: 1
                )
            )
        }
        do {
            try await store.add(product)
            items = await store.items
        } catch {
            items = previousItems
            self.error = error
        }
    }

    func increment(_ item: CartItem) async {
        let previousItems = items
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = CartItem(
                id: items[index].id,
                title: items[index].title,
                price: items[index].price,
                weight: items[index].weight,
                imageURL: items[index].imageURL,
                quantity: items[index].quantity + 1
            )
        }
        do {
            try await store.increment(item)
            items = await store.items
        } catch {
            items = previousItems
            self.error = error
        }
    }

    func decrement(_ item: CartItem) async {
        await remove(item)
    }

    func remove(_ item: CartItem) async {
        let previousItems = items
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].quantity > 1 {
                items[index] = CartItem(
                    id: items[index].id,
                    title: items[index].title,
                    price: items[index].price,
                    weight: items[index].weight,
                    imageURL: items[index].imageURL,
                    quantity: items[index].quantity - 1
                )
            } else {
                items.remove(at: index)
            }
        }
        do {
            try await store.remove(item)
            items = await store.items
        } catch {
            items = previousItems
            self.error = error
        }
    }
    
    func resetError() {
        error = nil 
    }
}
