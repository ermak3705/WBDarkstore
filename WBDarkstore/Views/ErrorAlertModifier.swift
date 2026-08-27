//
//  ErrorAlertModifier.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 26.08.2026.
//

import SwiftUI

extension View {

    func errorAlert(_ error: Error?, onDismiss: @escaping () -> Void) -> some View {
        alert(
            "Ошибка",
            isPresented: Binding(
                get: { error != nil },
                set: { isPresented in
                    if !isPresented { onDismiss() }
                }
            ),
            presenting: error
        ) { _ in
            Button("ОК", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
