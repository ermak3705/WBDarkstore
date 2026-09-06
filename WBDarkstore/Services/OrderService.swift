//
//  OrderService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 26.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class OrderService {
    private let client: Client

    private(set) var orders: [Order] = []
    private(set) var isLoading = false
    private(set) var isCreatingOrder = false
    var error: Error?

    init(client: Client) {
        self.client = client
    }

    func loadOrders() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getOrders()
            switch response {
            case .ok(let okResponse):
                let items = try okResponse.body.json
                orders = items.map { item in
                    Order(
                        id: item.id,
                        status: OrderStatus(rawValue: item.status.rawValue) ?? .active,
                        deliveryDate: item.deliveryDate,
                        addressLine: item.address.addressLine,
                        orderPrice: item.orderPrice,
                        deliveryPrice: item.deliveryPrice,
                        totalPrice: item.totalPrice,
                        totalItems: item.totalItems,
                        items: item.items.map { orderItem in
                            OrderItem(
                                id: orderItem.id,
                                imageURL: URL(string: orderItem.image),
                                title: orderItem.name,
                                weight: orderItem.weight,
                                price: orderItem.price,
                                quantity: orderItem.quantity
                            )
                        }
                    )
                }
            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    @discardableResult
    func createOrder(addressID: String, paymentMethod: String = "card") async -> Bool {
        isCreatingOrder = true
        error = nil
        defer { isCreatingOrder = false }

        do {
            let response = try await client.postOrders(
                body: .json(.init(paymentMethod: paymentMethod, addressID: addressID))
            )
            switch response {
            case .ok:
                return true
            case .badRequest(_):
                error = APIError.unexpected
            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
        return false
    }
}
