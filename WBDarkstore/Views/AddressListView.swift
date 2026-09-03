//
//  AddressListView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 28.08.2026.
//

import SwiftUI
import WBDesignSystemKit


struct AddressListView: View {
    
    @Environment(ServiceLocator.self) private var services
    @Environment(\.dismiss) private var dismiss

    @State private var showAddForm = false
    @State private var editingAddress: Address?
    
    private var addressSerbice: AddressService {
        services.addressService
    }

    private var addresses: [Address ] {
        addressSerbice.addresses
    }

    private var header: some View {
            HStack {
                Text("Мои адреса")
                    .font(DSTypography.title)
                    .foregroundColor(DSColors.textPrimary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    
    private var confirmButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Привезти сюда")
                .font(DSTypography.privestiSudaButton)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(DSGradients.violet)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(addressSerbice.selectedAddressID == nil)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var addNewAddressRow: some View {
        Button {
            showAddForm = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(DSColors.textSecondary)
                Text("Новый адрес")
                    .font(DSTypography.addressTypography)
                    .foregroundColor(DSColors.textPrimary)
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func addressRow(for address: Address) -> some View {
        let isSelected = address.id == addressSerbice.selectedAddressID

        Button {
            addressSerbice.selectedAddressID = address.id
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.addressLine)
                        .font(DSTypography.addressTypography)
                        .foregroundColor(DSColors.textPrimary)

                    if let details = detailsText(for: address) {
                        Text(details)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }

                Spacer()

                Button {
                    editingAddress = address
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func detailsText(for address: Address) -> String? {
        var parts: [String] = []
        if let entrance = address.entrance, !entrance.isEmpty {
            parts.append("Подъезд \(entrance)")
        }
        if let floor = address.floor, !floor.isEmpty {
            parts.append("Этаж \(floor)")
        }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            List {
                Section {
                    ForEach(addresses) { address in
                        addressRow(for: address)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await addressSerbice.delete(addresses[index])
                            }
                        }
                    }

                    addNewAddressRow
                        .listRowSeparator(.hidden, edges: .all)
                }
            }
            .listStyle(.plain)
            .overlay {
                if addressSerbice.isLoading && addresses.isEmpty {
                    ProgressView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            confirmButton
        }
        .sheet(isPresented: $showAddForm) {
            AddressMapPickerView()
        }
        .sheet(item: $editingAddress) { addres in
            AddressFormView(mode: .edit(addres))
        }
        .task {
            if addresses.isEmpty {
                await addressSerbice.loadAddresses()
            }
        }
        .errorAlert(addressSerbice.error) {
            addressSerbice.error = nil
        }
    }
}
