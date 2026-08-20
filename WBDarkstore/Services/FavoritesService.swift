//
//  FavoritesService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 05.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class FavoritesService {
    private let client: Client

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    init(client: Client) {
        self.client = client
    }

    func loadFavorites() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getProducts(query: .init(page: 1, pageSize: 200))
            switch response {
            case .ok(let okResponse):
                let items = try okResponse.body.json.data
                products = items.filter { $0.isFavorite }.map { item in
                    Product(
                        id: item.id,
                        title: item.name,
                        price: item.price,
                        imageURL: URL(string: item.image),
                        rating: Double(item.rating),
                        reviewCount: item.reviewCount,
                        weight: Int(item.weight)
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

    func isFavorite(_ product: Product) -> Bool {
        products.contains { $0.id == product.id }
    }

    func toggle(_ product: Product) async {
        do {
            if isFavorite(product) {
                let response = try await client.deleteProductsIdFavourite(path: .init(id: product.id))
                switch response {
                case .ok:
                    await loadFavorites()
                case .unauthorized(_):
                    error = APIError.unauthorized
                case .notFound(_):
                    error = APIError.unexpected
                case .default(statusCode: _, _):
                    error = APIError.unexpected
                }
            } else {
                let response = try await client.postProductsIdFavourite(path: .init(id: product.id))
                switch response {
                case .ok:
                    await loadFavorites()
                case .unauthorized(_):
                    error = APIError.unauthorized
                case .notFound(_):
                    error = APIError.unexpected
                case .default(statusCode: _, _):
                    error = APIError.unexpected
                }
            }
        } catch {
            self.error = error
        }
    }
}
