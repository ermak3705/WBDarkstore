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

    private(set) var productDetail: ProductDetail?
    private(set) var isLoadingDetail = false

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
                        id: item.id,
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

    func loadProductDetail(id: String) async {
        isLoadingDetail = true
        error = nil
        defer { isLoadingDetail = false }

        do {
            let response = try await client.getProductsId(path: .init(id: id))
            switch response {
            case .ok(let okResponse):
                let item = try okResponse.body.json
                productDetail = ProductDetail(
                    id: item.id,
                    title: item.name,
                    description: item.description,
                    price: item.price,
                    imageURL: URL(string: item.image)
                )
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
