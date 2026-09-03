//
//  CartActor.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.09.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import SwiftData

actor CartActor {
    private let client: Client
    private let modelContainer: ModelContainer
    
    private(set) var items: [CartItem] = []
    
    init(client: Client) {
        self.client = client
        do {
            self.modelContainer = try ModelContainer(for: CachedCartItem.self)
        } catch {
            fatalError("Не удалось создать локальное хранилище корзины: \(error)")
        }
    }
    
    func restoreFromCache() {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedCartItem>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        if let cached = try? context.fetch(descriptor), !cached.isEmpty {
            items = cached.map { entity in
                CartItem(
                    id: entity.id,
                    title: entity.title,
                    price: entity.price,
                    weight: entity.weight,
                    imageURL: entity.imageURLString.flatMap(URL.init(string:)),
                    quantity: entity.quantity
                )
            }
        }
    }
    
    private func saveToCache() {
        let context = ModelContext(modelContainer)
        try? context.delete(model: CachedCartItem.self)
        for (index, item) in items.enumerated() {
            context.insert(
                CachedCartItem(
                    id: item.id,
                    title: item.title,
                    price: item.price,
                    weight: item.weight,
                    imageURLString: item.imageURL?.absoluteString,
                    quantity: item.quantity,
                    sortOrder: index
                )
            )
        }
        try? context.save()
    }
    
    @discardableResult
    func loadCart() async throws -> [CartItem] {
        let response = try await client.getCart()
        switch response {
        case .ok(let okResponse):
            let body = try okResponse.body.json
            let newItems = body.items.map { item in
                CartItem(
                    id: item.value1.id,
                    title: item.value1.name,
                    price: item.value1.price,
                    weight: item.value1.weight,
                    imageURL: URL(string: item.value1.image),
                    quantity: item.value1.quantity
                )
            }
            
            var orderedItems: [CartItem] = []
            
            for existingItem in items {
                if let updated = newItems.first(where: {$0.id == existingItem.id}) {
                    orderedItems.append(updated)
                }
            }
            for newItem in newItems {
                if !orderedItems.contains(where: { $0.id == newItem.id}) {
                    orderedItems.append(newItem)
                }
            }
            items = orderedItems
            saveToCache()
            return items
            
        case .unauthorized:
            throw APIError.unauthorized
        case .default(statusCode: _, _):
            throw APIError.unexpected
        }
    }
    
    func add(_ product: Product) async throws {
        let response = try await client.postCartItems(query: .init(id: product.id))
        switch response {
        case .ok:
            try await loadCart()
        case .unauthorized:
            throw APIError.unauthorized
            
        case .notFound:
            throw APIError.unexpected
            
        case .default(statusCode: _, _):
            throw APIError.unexpected
        }
    }
    
    func increment (_ item: CartItem) async throws {
        let response = try await client.postCartItems(query: .init(id: item.id))
        switch response {
        case .ok:
            try await loadCart()
            
        case .unauthorized:
            throw APIError.unauthorized
            
        case .notFound:
            throw APIError.unexpected
        case .default(statusCode: _, _):
            throw APIError.unexpected
        }
    }
    
    func remove (_ item: CartItem) async throws {
        let response = try await client.deleteCartItemsId(path: .init(id: item.id))
        switch response {
        case .ok:
            try await loadCart()
            
        case .unauthorized:
            throw APIError.unauthorized
            
        case .notFound:
            throw APIError.unexpected
            
        case .default(statusCode: _, _):
            throw APIError.unexpected
        }
    }
}
