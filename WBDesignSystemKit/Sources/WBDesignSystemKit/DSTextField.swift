//
//  DSTextField.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 15.07.2026.
//

import SwiftUI

public struct DSTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    public init(placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }

    public var body: some View {
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
