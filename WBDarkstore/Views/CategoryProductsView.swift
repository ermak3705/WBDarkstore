//
//  CategoryProductsView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct CategoryProductsView: View {
    let category: Category
    let client: Client
    @Environment(ServiceLocator.self) private var services
    @State private var productsService: ProductsService
    @State private var selectedProduct: Product?
    @State private var showSearch = false

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    init(category: Category, client: Client) {
        self.category = category
        self.client = client
        _productsService = State(initialValue: ProductsService(client: client))
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Spacer()
            
            Text("Не удалось загрузить товары")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            Spacer()
            
            Text("Проверьте подключение к интернету и попробуйте ещё раз")
                .font(DSTypography.price)
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Повторить") {
                Task {
                    await productsService.loadProducts(category: category.id)
                }
            }
            .font(DSTypography.price)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(DSGradients.violet)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                if productsService.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if productsService.error != nil && productsService.products.isEmpty {
                    errorView
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(productsService.products) { product in
                            VStack(spacing: 8) {
                                Button {
                                    selectedProduct = product
                                } label: {
                                    ProductCard(product: product)
                                }
                                .buttonStyle(.plain)

                                ProductCartButton(product: product)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 60)
                }
            }

            HStack(spacing: 12) {
                Button {
                    showSearch = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Поиск")
                    }
                    .font(DSTypography.priceButton)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    }
                }

                if !services.cartService.items.isEmpty {
                    Button {
                        services.selectedTab = .cart
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("\(services.cartService.totalPrice)")
                                        .font(DSTypography.price)
                                    Text("₽")
                                        .font(DSTypography.rubIcon)
                                }
                                Text("\(services.cartService.totalCount) товара")
                                    .font(DSTypography.body)
                                    
                            }
                            Spacer()
                            Text("Оформить")
                                .font(DSTypography.priceButton)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(DSGradients.violet)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(category.name)
        .task {
            await productsService.loadProducts(category: category.id)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(productId: product.id)
        }
        .sheet(isPresented: $showSearch) {
            SearchView(productsService: services.productService)
        }
    }
}

#Preview {
    CategoryProductsView(
        category: Category(id: "1", name: "Выпечка", imageURL: nil),
        client: try! APIClientFactory.makeClient(token: Secrets.apiToken)
    )
    .environment(ServiceLocator())
}
