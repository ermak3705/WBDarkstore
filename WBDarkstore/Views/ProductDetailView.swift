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
    
    private var isFavorite: Bool {
        services.favoritesService.products.contains{ $0.id == productId}
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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text("\(detail.price)")
                                        .font(DSTypography.title)
                                    Text("₽")
                                        .font(DSTypography.title)
                                }
                                .foregroundColor(DSColors.textPrimary)

                                Spacer()

                                Button {
                                    let product = Product(id: detail.id, title: detail.title, price: detail.price, imageURL: detail.imageURL)
                                    services.favoritesService.toggle(product)
                                } label: {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(isFavorite ? .pink : .gray)
                                }
                            }
                            
                            Text(detail.title)
                                .font(DSTypography.title2)
                                .foregroundColor(DSColors.textPrimary)
                            
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
                    services.cartService.add(
                        Product(id: detail.id, title: detail.title, price: detail.price, imageURL: detail.imageURL)
                    )
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
    }
}





