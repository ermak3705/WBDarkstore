//
//  OrderDetailView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 05.09.2026.
//

import SwiftUI
import WBDesignSystemKit

struct OrderDetailView: View {
    let order: Order
    
    @Environment(\.dismiss) private var dismiss
    
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
    
    private var parsedDeliveryDate: Date? {
        guard let raw = order.deliveryDate else { return nil }
        return Self.isoFormatterFractional.date(from: raw) ?? Self.isoFormatter.date(from: raw)
    }
    
    private var etaMinutes: Int? {
        guard let date = parsedDeliveryDate else { return nil }
        let minutes = Int(ceil(date.timeIntervalSinceNow / 60))
        return max(minutes, 1)
    }
    
    private var headline: (line1: String, line2: String) {
        switch order.status {
        case .active:
            if let minutes = etaMinutes {
                return ("Доставим", "через \(minutes) \(minutes.pluralized(one: "минуту", few: "минуты", many: "минут"))")
            }
            return ("Ваш заказ", "готовится")
        case .completed:
            if let date = parsedDeliveryDate {
                return ("Доставили", Self.displayDateFormatter.string(from: date))
            }
            return ("Заказ", "доставлен")
        case .canceled:
            return ("Заказ", "отменён")
        }
    }
    
    private var itemsCountLabel: String {
        "\(order.totalItems) \(order.totalItems.pluralized(one: "товар", few: "товара", many: "товаров"))"
    }
    
    private var deliveryLabel: String {
        order.deliveryPrice == 0 ? "Бесплатно" : "\(order.deliveryPrice) ₽"
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(headline.line1)
                Text(headline.line2)
            }
            .font(DSTypography.title)
            .foregroundColor(.black)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    private func itemRow(for item: OrderItem) -> some View {
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
                Text("\(item.price) ₽, \(item.quantity) шт")
                    .font(DSTypography.price)
                    .foregroundColor(.black)

                HStack(spacing: 4) {
                    Text(item.title)
                        .font(DSTypography.body)
                        .foregroundColor(.black)
                    Text("\(item.weight) г")
                        .font(DSTypography.body)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
    }
    
    private var footer: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Итого")
                    .font(DSTypography.price)
                Spacer()
                Text("\(order.totalPrice) ₽")
                    .font(DSTypography.price)
            }
            .foregroundColor(.black)

            HStack {
                Text(itemsCountLabel)
                    .font(DSTypography.body)
                    .foregroundColor(.black)
                Spacer()
                Text("\(order.orderPrice) ₽")
                    .font(DSTypography.body)
                    .foregroundColor(.black)
            }

            HStack {
                Text("Доставка")
                    .font(DSTypography.body)
                    .foregroundColor(.black)
                Spacer()
                Text(deliveryLabel)
                    .font(DSTypography.body)
                    .foregroundColor(.black)
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                // логика
            } label: {
                Text("Скачать чек")
                    .font(DSTypography.privestiSudaButton)
                    .foregroundColor(.black)
                    .frame(width: 150)
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DSGradients.smoky, lineWidth: 2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                // логика
            } label: {
                Text("Повторить заказ")
                    .font(DSTypography.privestiSudaButton)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(DSGradients.violet)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    Text(order.addressLine)
                        .font(DSTypography.body)
                        .foregroundColor(.black)
                    
                    VStack(spacing: 16) {
                        ForEach(order.items) { item in
                            itemRow(for: item)
                        }
                    }
                }
                .padding(20)
            }
            
            VStack(spacing: 16) {
                footer
                actionButtons
            }
            .padding(20)
            .background(Color.white)
        }
    }
}

#Preview("Активный") {
    OrderDetailView(order: .mockActive)
}

#Preview("Завершён") {
    OrderDetailView(order: .mockCompleted)
}

private extension Order {
    static var mockActive: Order {
        Order(
            id: "1",
            status: .active,
            deliveryDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(12 * 60)),
            addressLine: "Комендантский проспект 17, к.1, кв. 210",
            orderPrice: 2330,
            deliveryPrice: 0,
            totalPrice: 2330,
            totalItems: 4,
            items: [
                OrderItem(id: "1", imageURL: nil, title: "Бутер", weight: 100, price: 900, quantity: 1),
                OrderItem(id: "2", imageURL: nil, title: "Огурец", weight: 80, price: 750, quantity: 1),
                OrderItem(id: "3", imageURL: nil, title: "Печенье", weight: 100, price: 680, quantity: 2),
            ]
        )
    }

    static var mockCompleted: Order {
        var order = mockActive
        order.status = .completed
        order.deliveryDate = ISO8601DateFormatter().string(from: Date())
        return order
    }
}
