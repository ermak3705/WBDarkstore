//
//  SearchView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct SearchView: View {
    @State private var searchService: SearchService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @FocusState private var isFocused: Bool

    init(productsService: ProductsService) {
        _searchService = State(initialValue: SearchService(productsService: productsService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if searchService.suggestions.isEmpty && !searchService.query.isEmpty {
                    Text("Ничего не найдено")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                } else {
                    List(searchService.suggestions) { product in
                        Button {
                            selectedProduct = product
                        } label: {
                            Text(product.title)
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск", text: Binding(
                        get: { searchService.query },
                        set: { searchService.query = $0 }
                    ))
                    .focused($isFocused)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
            .task {
                await searchService.loadAllProducts()
                isFocused = true
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(productId: product.id)
            }
        }
    }
}
