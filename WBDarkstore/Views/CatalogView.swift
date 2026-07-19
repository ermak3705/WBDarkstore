//
//  CatalogView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//
import Foundation
import SwiftUI

struct CatalogView: View {
    @State private var service: ProductsService

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    init(service: ProductsService) {
        _service = State(initialValue: service)
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Каталог")
            .task {
                await service.loadProducts()
            }
        }
    }
}

#Preview {
    CatalogView(service: ProductsService(client: try! APIClientFactory.makeClient(token: Secrets.apiToken)))
}
