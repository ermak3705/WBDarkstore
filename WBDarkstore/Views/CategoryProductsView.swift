//
//  CategoryProductsView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 16.07.2026.
//

import SwiftUI

struct CategoryProductsView: View {
    let category: Category
    @State private var service: ProductsService

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    init(category: Category, service: ProductsService) {
        self.category = category
        _service = State(initialValue: service)
    }

    var body: some View {
        ScrollView {
            if service.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(service.products) { product in
                        ProductCard(product: product)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(category.name)
        .task {
            await service.loadProducts(category: category.id)
        }
    }
}
