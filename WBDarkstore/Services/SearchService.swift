//
//  SearchService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class SearchService {
    private let client: Client

    private(set) var allProducts: [Product] = []
    private(set) var isLoading = false

    var query: String = "" {
        didSet {
            updateSuggestions()
        }
    }

    private(set) var suggestions: [Product] = []

    init(client: Client) {
        self.client = client
    }

    func loadAllProducts() async {
        guard allProducts.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        let service = ProductsService(client: client)
        await service.loadProducts(pageSize: 200)
        allProducts = service.products
    }

    private func updateSuggestions() {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        suggestions = allProducts.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }
}
