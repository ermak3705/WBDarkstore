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
                Text("\(services.cartService.totalCount) \(services.cartService.totalCount.pluralized(one: "товар", few: "товара", many: "товаров"))")
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
    
    private func addressLines(for address: Address) -> (main: String, details: String?) {
        guard let lastCommaIndex = address.addressLine.lastIndex(of: ",") else {
            return (address.addressLine, nil)
        }
        let main = String(address.addressLine[..<lastCommaIndex])
        let details = address.addressLine[address.addressLine.index(after: lastCommaIndex)...]
            .trimmingCharacters(in: .whitespaces)
        return (main, details.isEmpty ? nil : details)
    }
    
    private var selectedAddressRow: some View {
        Button {
            showAddressList = true
        } label: {
            HStack(spacing: 12) {

                if let address = services.addressService.addresses.first(where: {
                    $0.id == services.addressService.selectedAddressID
                }) {
                    let lines = addressLines(for: address)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lines.main)
                            .font(DSTypography.addressTypographyCart)
                            .foregroundColor(DSColors.textPrimary)
                            .lineLimit(1)

                        if let details = lines.details {
                            Text(details)
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textPrimary)
                                .lineLimit(1)
                        }
                    }
                } else {
                    Text("Выбрать адрес доставки")
                        .font(DSTypography.addressTypography)
                        .foregroundColor(DSColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DSGradients.smoky)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var paymentMethodRow: some View {
        HStack(spacing: 12) {
            Text("Оплата SberPay")
                .font(DSTypography.addressTypographyCart)
                .foregroundColor(DSColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DSGradients.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func placeOrder() async {
        guard let addressID = services.addressService.selectedAddressID else {return}
        
        let success = await services.orderService.createOrder(addressID: addressID)
        if success {
            await services.cartService.loadCart()
            await services.orderService.loadOrders()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.62)) {
                showOrderPlaced = true
            }        }
    }
    
    private var activeError: Error? {
        services.cartService.error ?? services.addressService.error ?? services.orderService.error
    }
    
    private func resetActiveError() {
        if services.cartService.error != nil {
            services.cartService.resetError()
        } else if services.addressService.error != nil {
            services.addressService.error = nil
        } else if services.orderService.error != nil {
            services.orderService.resetError()
        }
    }
    
    var body: some View {
        ZStack {
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
            }
            
            if showOrderPlaced {
                OrderPlacedView {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showOrderPlaced = false
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.75).combined(with: .opacity),
                        removal: .scale(scale: 0.92).combined(with: .opacity)
                    )
                )
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showAddressList) {
            AddressListView()
        }
        
        .onChange(of: showOrderPlaced) { wasShown, isShown in
            if wasShown && !isShown {
                services.selectedTab = .orders
                if let newOrder = services.orderService.orders.first {
                    services.router.push(.orderDetail(newOrder))
                }
            }
        }
        
        .errorAlert(activeError) {
            resetActiveError()
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
