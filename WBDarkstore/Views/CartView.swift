//
//  CartView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.07.2026.
//

import SwiftUI
import WBDesignSystemKit

struct CartView: View {
    @Environment(ServiceLocator.self) private var services
    @State private var refreshID = UUID()

    private var itemsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(services.cartService.totalCount) товара")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)

                VStack(spacing: 20) {
                    ForEach(services.cartService.items) { item in
                        cartRow(for: item)
                    }
                }
                .padding(.top, 16)
            }
            .padding(16)
        }
    }

    private func cartRow(for item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(DSColors.background)
                .frame(width: 100, height: 100)
                .overlay {
                    AsyncImage(url: item.imageURL) { phase in
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
                    .id("\(item.id)-\(refreshID)")
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(item.price * item.quantity)")
                        .font(DSTypography.price)
                    Text("₽")
                        .font(DSTypography.rubIcon)
                }
                .foregroundColor(DSColors.textPrimary)

                Text(item.title)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)

                DSStepper(
                    quantity: item.quantity,
                    onIncrement: {Task { await services.cartService.increment(item) }},
                    onDecrement: {Task { await services.cartService.decrement(item) }}
                )
                .padding(.top, 4)
            }

            Spacer()
        }
    }

    private var checkoutSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Итого")
                    .font(DSTypography.price)
                    .foregroundColor(DSColors.textPrimary)
                Spacer()
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(services.cartService.totalPrice)")
                        .font(DSTypography.price)
                    Text("₽")
                        .font(DSTypography.price)
                }
                .foregroundColor(DSColors.textPrimary)
            }
            .padding(.horizontal, 16)

            DSButton(title: "Оформить заказ") {
                // Логика
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(DSColors.background)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                itemsList
                if !services.cartService.items.isEmpty {
                    checkoutSection
                }
            }
            .navigationTitle("Корзина")
            .onAppear {
                refreshID = UUID()
            }
        }
    }
}

#Preview {
    CartView()
        .environment(ServiceLocator())
}
