//
//  OrderPlacedView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 29.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct OrderPlacedView: View {
    let onClose: (() -> Void)
    @State private var checkmarkScale: CGFloat = 0.3
    @State private var checkmarkOpacity: Double = 0
    
    private var checkmark: some View {
        Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .fontWeight(.light )
            .foregroundColor(.white )
            .frame (width: 135, height: 135 )
            .scaleEffect(checkmarkScale)
            .opacity(checkmarkOpacity)
    }
    
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        ZStack {
            DSGradients.violet.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    closeButton
                }.padding(16)
                
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    checkmark
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text ("Заказ оформлен")
                            .font(DSTypography.underCheckmark)
                            .foregroundColor(.white)
                        
                        Text ("Товары уже в процессе сборки,\nскоро привезем!")
                            .font(DSTypography.priceButton)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    onClose()
                } label: {
                    Text("Закрыть")
                        .font(DSTypography.priceButton)
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            checkmarkScale = 0.3
            checkmarkOpacity = 0
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.15)) {
                checkmarkScale = 1
                checkmarkOpacity = 1
            }
        }
    }
}


#Preview {
    OrderPlacedView(onClose: {})
}
