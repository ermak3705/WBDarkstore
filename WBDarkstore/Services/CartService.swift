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
    private let client: Client

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
        self.client = client
    }

    func loadCart() async {
        defer { isLoading = false }
        isLoading = true
        error = nil

        do {
            let response = try await client.getCart()
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                let newItems = body.items.map { item in
                    CartItem(
                        id: item.value1.id,
                        title: item.value1.name,
                        price: item.value1.price,
                        imageURL: URL(string: item.value1.image),
                        quantity: item.value1.quantity
                    )
                }
                // пытаюсь починить порядок добавления при увеличении счетчика товара в корзине 
                var orderedItems: [CartItem] = []
                for existingItem in items {
                    if let updated = newItems.first(where: { $0.id == existingItem.id }) {
                        orderedItems.append(updated)
                    }
                }
                for newItem in newItems {
                    if !orderedItems.contains(where: { $0.id == newItem.id }) {
                        orderedItems.append(newItem)
                    }
                }
                items = orderedItems

            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    func add(_ product: Product) async {
        do {
            let response = try await client.postCartItems(query: .init(id: product.id))
            switch response {
            case .ok:
                await loadCart()
            case .unauthorized(_):
                error = APIError.unauthorized
            case .notFound(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    func increment(_ item: CartItem) async {
        do {
            let response = try await client.postCartItems(query: .init(id: item.id))
            switch response {
            case .ok:
                await loadCart()
            case .unauthorized(_):
                error = APIError.unauthorized
            case .notFound(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    func decrement(_ item: CartItem) async {
        await remove(item)
    }

    func remove(_ item: CartItem) async {
        do {
            let response = try await client.deleteCartItemsId(path: .init(id: item.id))
            switch response {
            case .ok:
                await loadCart()
            case .unauthorized(_):
                error = APIError.unauthorized
            case .notFound(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }
}
