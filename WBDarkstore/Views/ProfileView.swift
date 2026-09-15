//
//  ProfileView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 12.09.2026.
//

import SwiftUI
import PhotosUI
import WBDesignSystemKit

struct ProfileView: View {
    let service: UserService

    @Environment(ServiceLocator.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var editedName: String = ""
    @State private var editedBirthday: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false

    private var isSaveEnabled: Bool {
        !editedName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editedBirthday.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var avatarView: some View {
        Group {
            if let pickedImageData, let uiImage = UIImage(data: pickedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = service.profile?.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    initialCircle
                }
            } else {
                initialCircle
            }
        }
        .clipShape(Circle())
    }

    private var initialCircle: some View {
        let initial = String(editedName.first ?? "?").uppercased()
        return Circle()
            .fill(Color(red: 0.91, green: 0.89, blue: 0.97))
            .overlay(
                Text(initial)
                    .font(.system(size: 32))
                    .foregroundColor(.black)
            )
    }

    private var avatarPicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            avatarView
                .frame(width: 88, height: 88)
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem, let rawData = try? await newItem.loadTransferable(type: Data.self) {
                    pickedImageData = resizedImageData(from: rawData)
                }
            }
        }
    }

    private func resizedImageData(from data: Data, maxDimension: CGFloat = 512, quality: CGFloat = 0.7) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            fieldRow(title: "Имя", text: $editedName)
            lockedFieldRow(title: "Телефон", value: service.profile?.phone ?? "")
            birthdayField
        }
        .padding(.horizontal)
    }

    private var saveButton: some View {
        Button {
            Task {
                await service.updateProfile(
                    name: editedName,
                    birthday: editedBirthday,
                    newImageData: pickedImageData
                )
                if service.error == nil {
                    dismiss()
                }
            }
        } label: {
            Text("Сохранить изменения")
                .font(DSTypography.privestiSudaButton)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(DSGradients.smoky)
        .foregroundColor(isSaveEnabled ? DSColors.textPrimary : DSColors.textSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .disabled(!isSaveEnabled || service.isLoading)
    }

    private var profileMenu: some View {
        Menu {
            Button("Выйти") { showLogoutConfirmation = true }
            Button("Удалить профиль", role: .destructive) { showDeleteConfirmation = true }
        } label: {
            Image(systemName: "ellipsis")
        }
    }

    private func fieldRow(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(DSTypography.body).foregroundColor(DSColors.textSecondary)
            TextField("", text: text)
                .font(DSTypography.filedRow)
            Divider()
        }
    }

    private func lockedFieldRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(DSTypography.body).foregroundColor(DSColors.textSecondary)
            HStack(spacing: 6) {
                Image(systemName: "lock.fill").font(DSTypography.body).foregroundColor(DSColors.textSecondary)
                Text(value).foregroundColor(DSColors.textSecondary)
                    .font(DSTypography.filedRow)
            }
            Divider()
        }
    }

    private var birthdayField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("День рождения").font(DSTypography.body).foregroundColor(DSColors.textSecondary)
            TextField("ДД.ММ.ГГГГ", text: $editedBirthday)
                .font(DSTypography.filedRow)
                .keyboardType(.numberPad)
                .onChange(of: editedBirthday) { _, newValue in
                    editedBirthday = formattedBirthday(from: newValue)
                }
            Divider()
        }
    }

    private func formattedBirthday(from input: String) -> String {
        let digits = input.filter(\.isNumber).prefix(8)
        var result = ""
        for (index, digit) in digits.enumerated() {
            if index == 2 || index == 4 {
                result.append(".")
            }
            result.append(digit)
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarPicker
                fieldsSection
                saveButton

                if let error = service.error {
                    Text("Ошибка: \(String(describing: error))")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                profileMenu
            }
        }
        .task {
            if service.profile == nil {
                await service.loadProfile()
            }
            editedName = service.profile?.name ?? ""
            editedBirthday = service.profile?.birthday ?? ""
        }

        .alert("Выйти из аккаунта?", isPresented: $showLogoutConfirmation) {
            Button("Выйти", role: .destructive) {
                services.authService.logout()
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Удалить профиль?", isPresented: $showDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                Task {
                    await service.deleteAccount()
                    if service.error == nil {
                        services.authService.logout()
                        dismiss()
                    }
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это действие необратимо")
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            service: UserService(previewProfile: UserProfile(
                name: "Анастасия",
                phone: "+7 908 305-80-34",
                birthday: "18.07.1992",
                imageURL: nil
            ))
        )
    }
    .environment(ServiceLocator())
}
