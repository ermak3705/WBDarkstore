//
//  ProductsService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.07.2026.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class ProductsService {

    private let client: Client

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    init(client: Client) {
        self.client = client
    }
    
    func loadProducts(category: String? = nil, page: Int = 1, pageSize: Int = 200) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getProducts(query: .init(
                category: category, page: page, pageSize: pageSize
            ))
            switch response {
            case .ok(let okResponse):
                let items = try okResponse.body.json.data
                products = items.map { item in
                    Product(
                        title: item.name,
                        price: item.price,
                        imageURL: URL(string: item.image)
                    )
                }
            case .unauthorized(_):
                error = APIError.unauthorized
            case .badRequest(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }
}
