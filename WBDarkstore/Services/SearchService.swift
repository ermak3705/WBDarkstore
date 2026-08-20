//
//  SearchService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.08.2026.
//

import Foundation

@Observable
final class SearchService {
    private let productsService: ProductsService

    var query: String = "" {
        didSet {
            updateSuggestions()
        }
    }

    private(set) var suggestions: [Product] = []

    init(productsService: ProductsService) {
        self.productsService = productsService
    }

    func loadAllProducts() async {
        guard productsService.products.isEmpty else { return }
        await productsService.loadProducts(pageSize: 200)
    }

    private func updateSuggestions() {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        suggestions = productsService.products.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }
}
