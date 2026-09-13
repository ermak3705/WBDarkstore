//
//  OrderListView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 08.09.2026.
//

import SwiftUI
import WBDesignSystemKit

struct OrderListView: View {

    private let maxRecentOrders = 10
    private let maxVisibleThumbnails = 4

    @Environment(ServiceLocator.self) private var services

    private static let isoFormatterFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM 'в' HH:mm"
        return formatter
    }()

    private var recentOrders: [Order] {
        Array(services.orderService.orders.prefix(maxRecentOrders))
    }

    private var isInitialLoading: Bool {
        services.orderService.isLoading && services.orderService.orders.isEmpty
    }

    private func parsedDeliveryDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        return Self.isoFormatterFractional.date(from: raw) ?? Self.isoFormatter.date(from: raw)
    }

    private func statusLine(for order: Order) -> String {
        switch order.status {
        case .active:
            return "В пути"
        case .completed:
            if let date = parsedDeliveryDate(order.deliveryDate) {
                return "Доставили \(Self.displayDateFormatter.string(from: date))"
            }
            return "Доставлен"
        case .canceled:
            return "Отменён"
        }
    }

    private func thumbnailsRow(for order: Order) -> some View {
        let visibleItems = Array(order.items.prefix(maxVisibleThumbnails))
        let hiddenCount = order.items.count - visibleItems.count

        return HStack(spacing: 8) {
            ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DSColors.background)
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
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if index == visibleItems.count - 1 && hiddenCount > 0 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.45))
                        Text("+\(hiddenCount)")
                            .font(DSTypography.body)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 44, height: 44)
            }
            Spacer()
        }
    }
    
    private func orderRow(for order: Order) -> some View {
        NavigationLink(value: Route.orderDetail(order)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(order.totalPrice)")
                                .font(DSTypography.price)
                            Text("₽")
                                .font(DSTypography.price)
                            Text("\(order.totalItems) \(order.totalItems.pluralized(one: "товар", few: "товара", many: "товаров"))")
                                .font(DSTypography.price)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        .foregroundColor(DSColors.textPrimary)
                        
                        Text(statusLine(for: order))
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                thumbnailsRow(for: order)
            }
            .padding(16)
            .background(DSGradients.smoky)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.system(size: 40))
                .foregroundColor(DSColors.textSecondary)
            Text("У вас пока нет заказов")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        @Bindable var router = services.router
        NavigationStack(path: $router.path) {
            Group {
                if isInitialLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if recentOrders.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("История заказов")
                                .font(DSTypography.title)
                                .foregroundColor(DSColors.textPrimary)
                            
                            VStack(spacing: 12) {
                                ForEach(recentOrders) { order in
                                    orderRow(for: order)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .refreshable {
                        await services.orderService.loadOrders()
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .orderDetail(let order):
                    OrderDetailView(order: order)
                        .toolbar(.hidden, for: .navigationBar)
                default:
                    EmptyView()
                }
            }
        }
        .errorAlert(services.orderService.error) {
            services.orderService.resetError()
        }
        .task {
            await services.orderService.loadOrders()
        }
    }
}

#Preview {
    OrderListView()
        .environment(ServiceLocator())
}


