//
//  CartView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.07.2026.
//

import SwiftUI
import WBDesignSystemKit

struct CartView: View {
    
    @State private var showAddressList = false
    @State private var showOrderPlaced = false
    
    @Environment(ServiceLocator.self) private var services
    
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
                    CachedAsyncImage(url: item.imageURL) { phase in
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
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(item.price * item.quantity)")
                        .font(DSTypography.price)
                    Text("₽")
                        .font(DSTypography.rubIcon)
                }
                .foregroundColor(DSColors.textPrimary)
                
                HStack(spacing: 4) {
                    Text(item.title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    Text("· \(item.weight) г")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                }

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
                Task {await placeOrder() }
            }
            .disabled(services.addressService.selectedAddressID == nil || services.orderService.isCreatingOrder)
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(DSColors.background)
    }

    private var selectedAddressRow: some View {
        Button {
            showAddressList = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)

                if let address = services.addressService.addresses.first(where: {
                    $0.id == services.addressService.selectedAddressID
                }) {
                    Text(address.addressLine)
                        .font(DSTypography.addressTypography)
                        .foregroundColor(DSColors.textPrimary)
                        .lineLimit(1)
                } else {
                    Text("Выбрать адрес доставки")
                        .font(DSTypography.addressTypography)
                        .foregroundColor(DSColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DSColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var paymentMethodRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 20))
                .foregroundColor(DSColors.textSecondary)
            Text("Оплата картой")
                .font(DSTypography.addressTypography)
                .foregroundColor(DSColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DSColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func placeOrder() async {
        guard let addressID = services.addressService.selectedAddressID else {return}
        
        let success = await services.orderService.createOrder(addressID: addressID)
        if success {
            await services.cartService.loadCart()
            showOrderPlaced = true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if services.cartService.isLoading && services.cartService.items.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    itemsList
                    if !services.cartService.items.isEmpty {
                        VStack(spacing: 12) {
                            selectedAddressRow
                            paymentMethodRow
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        checkoutSection
                    }
                }
            }
            .navigationTitle("Корзина")
            .errorAlert(services.cartService.error) {
                services.cartService.error = nil
            }
        }
        .sheet(isPresented: $showAddressList) {
            AddressListView()
        }
        .fullScreenCover(isPresented: $showOrderPlaced) {
            OrderPlacedView {
                showOrderPlaced = false
            }
        }
        .errorAlert(services.addressService.error) {
            services.addressService.error = nil
        }
        .errorAlert(services.orderService.error) {
            services.orderService.error = nil
        }
        .task {
            await services.cartService.loadCart()
            await services.addressService.loadAddresses()
        }
    }
}

#Preview {
    CartView()
        .environment(ServiceLocator())
}
