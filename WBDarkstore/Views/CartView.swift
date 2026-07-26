//
//  CartView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.07.2026.
//

import SwiftUI

struct CartView: View {
    @Environment(ServiceLocator.self) private var services
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(services.cartService.totalCount) товара")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)

                    VStack(spacing: 20) {
                        ForEach(services.cartService.items) { item in
                            HStack(alignment: .top, spacing: 12) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DSColors.background)
                                    .frame(width: 100, height: 100)
                                    .overlay {
                                        AsyncImage(url: item.product.imageURL) { phase in
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
                                        Text("\(item.product.price)")
                                            .font(DSTypography.price)
                                        Text("₽")
                                            .font(DSTypography.rubIcon)
                                    }
                                    .foregroundColor(DSColors.textPrimary)

                                    Text(item.product.title)
                                        .font(DSTypography.body)
                                        .foregroundColor(DSColors.textPrimary)

                                    DSStepper(
                                        quantity: item.quantity,
                                        onIncrement: { services.cartService.increment(item) },
                                        onDecrement: { services.cartService.decrement(item) }
                                    )
                                    .padding(.top, 4)
                                }

                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(16)
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
