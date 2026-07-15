//
//  DSButton.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 14.07.2026.
//

import SwiftUI

struct DSButton: View {
    var price: String? = nil
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let price {
                    Text(price)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 20, weight: price == nil ? .semibold : .medium))
                        .frame(maxWidth: price == nil ? .infinity : nil)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(DSGradients.violet)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        DSButton(price: "900 ₽", title: "Оформить") {}
        DSButton(title: "В корзину") {}
        DSButton(title: "Войти") {}
        DSButton(title: "Загрузка...", isLoading: true) {}
    }
    .padding()
}
