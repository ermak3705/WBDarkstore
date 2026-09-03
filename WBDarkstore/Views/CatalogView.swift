//
//  CatalogView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 02.07.2026.
//
import Foundation
import SwiftUI
import WBDesignSystemKit

struct CatalogView: View {
    @Environment(ServiceLocator.self) private var services
    @State private var showSearch = false

    let columns: [GridItem] = [
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12),
        .init(.flexible(), spacing: 12)
    ]

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            if services.categoryService.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else {
                categoriesGrid
            }
        }
    }

    private var categoriesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(services.categoryService.categories) { category in
                categoryCard(for: category)
            }
        }
        .padding(16)
        .padding(.bottom, 60)
    }

    private func categoryCard(for category: Category) -> some View {
        NavigationLink(value: category) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .aspectRatio(115/132, contentMode: .fit)
                .overlay {
                    AsyncImage(url: category.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .overlay {
                    GeometryReader { geometry in
                        LinearGradient(colors: [
                            .clear,
                            .white.opacity(0.4),
                            .white.opacity(0.5),
                            .white.opacity(0.6),
                            .white.opacity(0.8),
                            .white.opacity(0.9),
                            .white.opacity(0.95),
                            .white
                        ],
                                       startPoint: .top,
                                       endPoint: .bottom)
                        .frame(height: geometry.size.height * (1/3))
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height * (5/6))
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Text(category.name)
                        .font(DSTypography.headline)
                        .foregroundColor(.black)
                        .padding(.bottom, 6)
                        .padding(.leading, 8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
            searchButton

            if !services.cartService.items.isEmpty {
                checkoutButton
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var searchButton: some View {
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
    }

    private var checkoutButton: some View {
        Button {
            // работа кнопки позже
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 4) {
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
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            bottomToolbar
        }
        .task {
            await services.categoryService.loadCategories()
        }
        .navigationTitle("Категории")
        .sheet(isPresented: $showSearch) {
            SearchView(productsService: services.productService)
        }
    }
}

#Preview {
    NavigationStack {
        CatalogView()
            .environment(ServiceLocator())
    }
}
