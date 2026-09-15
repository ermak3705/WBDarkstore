//
//  TopBarView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 13.09.2026.
//

import SwiftUI
import WBDesignSystemKit

struct TopBarView: View {
    @Environment(ServiceLocator.self) private var services
    @State private var showAddressList = false

    private var selectedAddressLine: String {
        services.addressService.addresses
            .first(where: { $0.id == services.addressService.selectedAddressID })?
            .addressLine ?? "Выберите адрес"
    }

    private var avatarInitial: String {
        String(services.userService.profile?.name.first ?? "?").uppercased()
    }

    private var addressButton: some View {
        Button {
            showAddressList = true
        } label: {
            HStack(spacing: 4) {
                Text(selectedAddressLine)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var profileLink: some View {
        NavigationLink {
            ProfileView(service: services.userService)
        } label: {
            Circle()
                .fill(Color(red: 0.91, green: 0.89, blue: 0.97))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(avatarInitial)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                )
        }
    }

    var body: some View {
        HStack {
            addressButton
            Spacer()
            profileLink
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DSGradients.smoky)
        )
        .padding(.horizontal, 16)
        .sheet(isPresented: $showAddressList) {
            AddressListView()
        }
        .task {
            if services.userService.profile == nil {
                await services.userService.loadProfile()
            }
            if services.addressService.addresses.isEmpty {
                await services.addressService.loadAddresses()
            }
        }
    }
}
