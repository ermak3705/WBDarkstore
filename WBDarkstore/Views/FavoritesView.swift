//
//  FavoritesView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 07.08.2026.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(ServiceLocator.self) private var services
    @State private var selectedProduct: Product?
    @State private var refreshID = UUID()

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Список избранного пуст")
                .foregroundColor(.gray)
        }
        .padding(.top, 100)
    }

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if services.favoritesService.products.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(services.favoritesService.products) { product in
                            VStack(spacing: 8) {
                                Button {
                                    selectedProduct = product
                                } label: {
                                    ProductCard(product: product)
                                        .id("\(product.id)-\(refreshID)")
                                }
                                .buttonStyle(.plain)

                                ProductCartButton(product: product)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Избранное")
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(productId: product.id)
            }
            .onAppear {
                refreshID = UUID()
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environment(ServiceLocator())
}
