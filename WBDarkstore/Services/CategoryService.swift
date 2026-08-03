//
//  CategoryService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 04.07.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class CategoriesService {

    private let client: Client

    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    init(client: Client) {
        self.client = client
    }

    func loadCategories() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getCategories()
            switch response {
            case .ok(let okResponse):
                let items = try okResponse.body.json
                categories = items.map { item in
                    Category(id: item.id, name: item.name, imageURL: URL(string: item.image))
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
}
