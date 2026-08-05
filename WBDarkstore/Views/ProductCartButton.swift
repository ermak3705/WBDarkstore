//
//  ProductCartButton.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 04.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct ProductCartButton: View {
    let product: Product
    @Environment(ServiceLocator.self) private var services

    private var cartItem: CartItem? {
        services.cartService.items.first { $0.product.id == product.id }
    }

    var body: some View {
        if let cartItem {
            HStack(spacing: 8) {
                Button {
                    services.cartService.decrement(cartItem)
                } label: {
                    Image(systemName: "minus")
                        .font(DSTypography.rubIcon)
                }

                HStack(spacing: 2) {
                    Text("\(cartItem.quantity * product.price)")
                    Text("₽")
                }
                .font(DSTypography.rubIcon)

                Button {
                    services.cartService.increment(cartItem)
                } label: {
                    Image(systemName: "plus")
                        .font(DSTypography.rubIcon)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DSGradients.violet)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Button {
                services.cartService.add(product)
            } label: {
                Text("В корзину")
                    .font(DSTypography.rubIcon)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ProductCartButton(product: Product(id: "1", title: "Бутер", price: 900, imageURL: nil))
        ProductCartButton(product: Product(id: "2", title: "Хлеб", price: 65, imageURL: nil))
    }
    .environment(ServiceLocator())
    .frame(width: 160)
    .padding()
}

