//
//  DSCard.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 15.07.2026.
//

import SwiftUI

struct DSCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(DSColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DSCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Заголовок")
                .font(DSTypography.headline)
            Text("Описание содержимого карточки.")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
    }
    .padding()
}
