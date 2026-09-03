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
    
    private var checkmark: some View {
        Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .fontWeight(.light )
            .foregroundColor(.white )
            .frame (width: 135, height: 135 )
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
    }
}


#Preview {
    OrderPlacedView(onClose: {})
}
