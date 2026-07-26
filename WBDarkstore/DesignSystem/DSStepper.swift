//
//  DSStepper.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 24.07.2026.
//

import SwiftUI

struct DSStepper: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View{
        HStack(spacing: 16) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
            }

            Text("\(quantity)")
                .font(DSTypography.headline)
                .frame(minWidth: 16)

            Button(action: onIncrement){
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .foregroundColor(DSColors.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(DSColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DSStepper(quantity: 3, onIncrement: {}, onDecrement: {})
        .padding()
}
