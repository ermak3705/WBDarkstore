//
//  ProductDetailView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 21.07.2026.
//

import SwiftUI
import WBDesignSystemKit

struct ProductDetailView: View {
    let productId: String
    @Environment(ServiceLocator.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var showReviews = false
    
    private var isFavorite: Bool {
        services.favoritesService.products.contains{ $0.id == productId}
    }

    private func ratingRow(_ detail: ProductDetail) -> some View {
        let summary = ReviewsSummary(reviews: detail.reviews)

        return Button {
            showReviews = true
        } label: {
            HStack(spacing: 8) {
                Text(String(format: "%.1f", summary.averageRating))
                    .font(.system(size: 16,weight: .regular))
                HStack(spacing: 1) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(summary.averageRating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(.black)
                
                HStack (spacing: 4) {
                    Image(systemName: "message")
                        .font(.system(size: 12))
                    Text("\(summary.totalCount) отзыв >")
                        .font(.system(size: 16,weight: .regular))
                }
            }
            .font(DSTypography.body)
            .foregroundColor(DSColors.textPrimary)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if services.productService.isLoadingDetail {
                    ProgressView()
                        .padding(.top, 40)
                } else if let detail = services.productService.productDetail {
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(DSColors.background)
                                .aspectRatio(375/440, contentMode: .fit)
                                .overlay {
                                    AsyncImage(url: detail.imageURL) { phase in
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
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            .padding(12)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text("\(detail.price)")
                                        .font(DSTypography.title)
                                    Text("₽")
                                        .font(DSTypography.title)
                                }
                                .foregroundColor(DSColors.textPrimary)

                                Spacer()

                                Button { Task {
                                    let product = Product(id: detail.id, title: detail.title, price: detail.price, imageURL: detail.imageURL, rating: detail.rating, reviewCount: detail.reviews.count, weight: detail.weight)
                                   await services.favoritesService.toggle(product)
                                }
                                } label: {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(isFavorite ? .pink : .gray)
                                }
                            }
                            
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(detail.title)
                                    .font(DSTypography.title2)
                                    .foregroundColor(DSColors.textPrimary)
                                Text("\(detail.weight)г")
                                    .font(DSTypography.title2)
                                    .foregroundColor(DSColors.textSecondary)
                            }

                            ratingRow(detail)
                            
                            Text(detail.description)
                                .font(DSTypography.title3)
                                .foregroundColor(DSColors.textPrimary)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }

            if let detail = services.productService.productDetail {
                DSButton(title: "В корзину") {
                    Task {
                        await services.cartService.add(
                            Product(id: detail.id, title: detail.title, price: detail.price, imageURL: detail.imageURL, rating: detail.rating, reviewCount: detail.reviews.count, weight: detail.weight)
                        )
                        dismiss()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(DSColors.background)
            }
        }
        .task {
            await services.productService.loadProductDetail(id: productId)
        }
        .sheet(isPresented: $showReviews) {
            if let detail = services.productService.productDetail {
                ReviewsView(detail: detail)
            }
        }
    }
}





