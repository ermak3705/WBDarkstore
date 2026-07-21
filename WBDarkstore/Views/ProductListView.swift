//
//  ProductListView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 21.07.2026.
//

import SwiftUI

struct ProductListView: View {
    @Environment(ServiceLocator.self) private var services
    
    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if services.productService.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(services.productService.products) {product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Каталог")
            .task {
                await services.productService.loadProducts()
            }
        }
    }
}

#Preview {
    ProductListView()
        .environment(ServiceLocator())
}
