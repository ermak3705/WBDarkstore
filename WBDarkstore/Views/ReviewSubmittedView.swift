//
//  ReviewSubmittedView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 27.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct ReviewSubmittedView: View {
    let onClose: () -> Void

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .fontWeight(.light)
            .foregroundColor(.white)
            .frame(width: 135, height: 135)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }

    var body: some View {
        ZStack {
            DSGradients.violet
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    closeButton
                }
                .padding(16)

                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    checkmark

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Отзыв отправлен")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundColor(.white)

                        Text("Спасибо!\nСкоро мы его опубликуем")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

                Button("Закрыть", action: onClose)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    ReviewSubmittedView(onClose: {})
}
