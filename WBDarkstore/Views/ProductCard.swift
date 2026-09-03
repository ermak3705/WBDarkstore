//
//  ProductCard.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 21.07.2026.
//

import SwiftUI
import WBDesignSystemKit

struct ProductCard: View {
    let product: Product
    @Environment(ServiceLocator.self) private var services

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    AsyncImage(url: product.imageURL) { phase in
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
                .overlay(alignment: .topTrailing) {
                    Button {
                        Task {
                            await services.favoritesService.toggle(product)
                        }
                    } label: {
                        Image(systemName: services.favoritesService.isFavorite(product) ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(services.favoritesService.isFavorite(product) ? .pink : Color(uiColor: .systemGray3))
                    }
                    .padding(12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(product.price)")
                    .font(DSTypography.price)
                    .foregroundColor(DSColors.textPrimary)
                Text("₽")
                    .font(DSTypography.rubIcon)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            HStack (spacing: 8) {
                Text(product.title)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(1)
                Text("\(product.weight) г")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                Text(String(format: "%.1f", product.rating))
                    .font(DSTypography.body)
                Image(systemName: "message")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                Text("\(product.reviewCount)")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
            }
            .font(.system(size: 12))

        }
    }
}

#Preview {
    ProductCard(product: Product(id: "1", title: "Бутер ЛЮКС", price: 1400, imageURL: nil, rating: 4.3, reviewCount: 120, weight: 100))
        .environment(ServiceLocator())
        .frame(width: 160)
        .padding()
}
