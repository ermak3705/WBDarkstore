//
//  ProductCard.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 16.07.2026.
//

import SwiftUI

struct ProductCard: View {
    let product: Product

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
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text("\(product.price)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text("₽")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }


            Text(product.title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

#Preview {
    ProductCard(product: Product(title: "Бутер ЛЮКС", price: 1400, imageURL: nil))
        .frame(width: 160)
        .padding()
}
