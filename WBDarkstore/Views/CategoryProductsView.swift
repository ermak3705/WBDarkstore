//
//  CategoryProductsView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.08.2026.
//

import SwiftUI

struct CategoryProductsView: View {
    let category: Category
    @State private var productsService: ProductsService
    @State private var selectedProduct: Product?

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    init(category: Category, client: Client) {
        self.category = category
        _productsService = State(initialValue: ProductsService(client: client))
    }

    var body: some View {
        ScrollView {
            if productsService.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(productsService.products) { product in
                        Button {
                            selectedProduct = product
                        } label: {
                            ProductCard(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(category.name)
        .task {
            await productsService.loadProducts(category: category.id)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(productId: product.id)
        }
    }
}

