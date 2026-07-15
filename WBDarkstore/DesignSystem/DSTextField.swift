//
//  DSTextField.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 15.07.2026.
//

import SwiftUI

struct DSTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(DSTypography.body)
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(DSColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    @Previewable @State var text = ""
    return DSTextField(placeholder: "Логин", text: $text)
        .padding()
}
