//
//  AddressMapPickerView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 28.08.2026.
//

import SwiftUI
import MapKit
import WBDesignSystemKit

struct AddressMapPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.9311, longitude: 30.3609),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 59.9311, longitude: 30.3609)
    @State private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    @State private var resolvedAddress = "Определяем адрес..."
    @State private var isResolvingAddress = false
    @State private var showManualEntry = false
    @State private var showAddressForm = false

    private let geocoder = CLGeocoder()

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
                .frame(width: 40, height: 40)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
    }
    
    private var pinWithTimePill: some View {
        VStack(spacing: 6) {
            Text("15 мин")
                .font(DSTypography.price)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.purple)
                .clipShape(Capsule())
            
            Image(systemName: "mappin")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.purple)
        }
        .offset(y: -40)
    }

    private var addressPreviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.purple)
                Text(resolvedAddress)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(2)
                if isResolvingAddress {
                    ProgressView()
                }
            }

            HStack(spacing: 12) {
                Button {
                    showManualEntry = true
                } label: {
                    Text("Ввести другой")
                        .font(DSTypography.privestiSudaButton)
                        .foregroundColor(DSColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(DSColors.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    showAddressForm = true
                } label: {
                    Text("Выбрать адрес")
                        .font(DSTypography.privestiSudaButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(DSGradients.violet)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isResolvingAddress)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func resolveAddress(for coordinate: CLLocationCoordinate2D) {
        Task {
            isResolvingAddress = true
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    var parts: [String] = []
                    if let street = placemark.thoroughfare { parts.append(street) }
                    if let houseNumber = placemark.subThoroughfare { parts.append(houseNumber) }
                    resolvedAddress = parts.isEmpty ? (placemark.name ?? "Адрес не найден") : parts.joined(separator: ", ")
                } else {
                    resolvedAddress = "Не удалось определить адрес"
                }
            } catch {
                resolvedAddress = "Не удалось определить адрес"
            }
            isResolvingAddress = false
        }
    }
    
    private func zoom(by factor: Double) {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(0.002, min(60, currentSpan.latitudeDelta * factor)),
            longitudeDelta: max(0.002, min(60, currentSpan.longitudeDelta * factor))
        )
        currentSpan = newSpan
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(center: centerCoordinate, span: newSpan))
        }
    }
    
    private var zoomControls: some View {
        VStack(spacing: 0) {
            Button {
                zoom(by: 0.5)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                    .frame(width: 40, height: 40)
            }
            
            Divider()
                .frame(width: 24)
            
            Button {
                zoom(by: 2)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                    .frame(width: 40, height: 40)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .onMapCameraChange(frequency: .onEnd) { context in
                    centerCoordinate = context.region.center
                    currentSpan = context.region.span
                    resolveAddress(for: centerCoordinate)
                }

            pinWithTimePill

            VStack {
                HStack {
                    Spacer()
                    closeButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                HStack {
                    Spacer()
                    zoomControls
                        .padding(.trailing, 16)
                        .padding(.bottom, 12)
                }
                
                
                addressPreviewCard
            }
        }
        .onAppear {
            resolveAddress(for: centerCoordinate)
        }
        .sheet(isPresented: $showManualEntry) {
            AddressFormView(
                mode: .add(addressLine: "", coordinates: [centerCoordinate.longitude, centerCoordinate.latitude]),
                onSaved: { dismiss() }
            )
        }
        .sheet(isPresented: $showAddressForm) {
            AddressFormView(
                mode: .add(
                    addressLine: resolvedAddress,
                    coordinates: [centerCoordinate.longitude, centerCoordinate.latitude]
                ),
                onSaved: { dismiss() }
            )
        }
    }
}
