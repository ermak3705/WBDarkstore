//
//  LoaderView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 05.09.2026.
//

import SwiftUI
import WBDesignSystemKit

struct LoaderView: View {
    
    var body: some View {
        ZStack {
            Color(DSColors.loaderBackground)
                .ignoresSafeArea()
            
            Image("White Loader")
                .resizable()
                .scaledToFit()
                .frame(width: 550, height: 400)
                .rotationEffect(Angle(degrees: 15))
 
        }
    }
}

#Preview {
    LoaderView()
}
