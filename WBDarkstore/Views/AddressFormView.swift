//
//  AddressFormView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 28.08.2026.
//

import SwiftUI
import WBDesignSystemKit

struct AddressFormView: View {
    enum Mode {
        case add(addressLine: String, coordinates: [Double])
        case edit(Address)
    }

    let mode: Mode
    
    var onSaved: (() -> Void)? = nil
    
    @Environment(ServiceLocator.self) private var services
    @Environment(\.dismiss) private var dismiss

    @State private var addressLine: String
    @State private var apartment: String = ""
    @State private var entrance: String
    @State private var floor: String
    @State private var intercomCode: String
    @State private var comment: String
    @State private var isSaving = false

    init(mode: Mode, onSaved: (() -> Void)? = nil) {
        self.mode = mode
        self.onSaved = onSaved
        switch mode {
        case .add(let addressLine, _):
            _addressLine = State(initialValue: addressLine)
            _entrance = State(initialValue: "")
            _floor = State(initialValue: "")
            _intercomCode = State(initialValue: "")
            _comment = State(initialValue: "")
        case .edit(let address):
            _addressLine = State(initialValue: address.addressLine)
            _entrance = State(initialValue: address.entrance ?? "")
            _floor = State(initialValue: address.floor ?? "")
            _intercomCode = State(initialValue: address.intercomCode ?? "")
            _comment = State(initialValue: address.comment ?? "")
        }
    }

    private var addressService: AddressService {
        services.addressService
    }

    private var coordinates: [Double] {
        switch mode {
        case .add(_, let coordinates):
            return coordinates
        case .edit(let address):
            return address.coordinates
        }
    }

    private var titleText: String {
        switch mode {
        case .add: return "Новый адрес"
        case .edit: return "Изменить адрес"
        }
    }

    private var header: some View {
        HStack {
            Text(titleText)
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

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            Group {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Сохранить")
                        .font(DSTypography.privestiSudaButton)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(DSGradients.violet)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .disabled(isSaving || addressLine.trimmingCharacters(in: .whitespaces).isEmpty)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        var finalAddressLine = addressLine
        let trimmedApartment = apartment.trimmingCharacters(in: .whitespaces)
        if !trimmedApartment.isEmpty {
            finalAddressLine += ", кв./офис \(trimmedApartment)"
        }

        let success: Bool
        switch mode {
        case .add:
            let newAddress = Address(
                id: UUID().uuidString,
                addressLine: finalAddressLine,
                coordinates: coordinates,
                floor: floor.isEmpty ? nil : floor,
                entrance: entrance.isEmpty ? nil : entrance,
                intercomCode: intercomCode.isEmpty ? nil : intercomCode,
                comment: comment.isEmpty ? nil : comment
            )
            success = await addressService.add(newAddress)

        case .edit(let existing):
            var updated = existing
            updated.addressLine = finalAddressLine
            updated.floor = floor.isEmpty ? nil : floor
            updated.entrance = entrance.isEmpty ? nil : entrance
            updated.intercomCode = intercomCode.isEmpty ? nil : intercomCode
            updated.comment = comment.isEmpty ? nil : comment
            success = await addressService.update(updated)
        }

        if success {
            dismiss()
            onSaved?()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DSTextField(placeholder: "Адрес", text: $addressLine)
                    DSTextField(placeholder: "Квартира/офис", text: $apartment)
                    DSTextField(placeholder: "Подъезд", text: $entrance)
                    DSTextField(placeholder: "Этаж", text: $floor)
                    DSTextField(placeholder: "Код домофона", text: $intercomCode)
                    DSTextField(placeholder: "Комментарий", text: $comment)
                }
                .padding(16)
            }

            saveButton
        }
        .errorAlert(addressService.error) {
            addressService.error = nil
        }
    }
}
