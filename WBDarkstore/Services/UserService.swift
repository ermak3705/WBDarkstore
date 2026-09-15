//
//  UserService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation
import SwiftUI
import UIKit
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class UserService {
    private let client: Client

    private(set) var profile: UserProfile?
    private(set) var isLoading = false
    private(set) var error: Error?

    private var hasCustomPhoto: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCustomProfilePhoto") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCustomProfilePhoto") }
    }

    init(client: Client) {
        self.client = client
    }

    func loadProfile() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getUsersMe()
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                profile = UserProfile(
                    name: body.name,
                    phone: body.phone,
                    birthday: body.birthday,
                    imageURL: body.imageUrl.flatMap { URL(string: $0) }
                )
            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    func updateProfile(name: String, birthday: String, newImageData: Data? = nil) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let imageUri: String
            if let newImageData {
                imageUri = try await uploadImage(newImageData)
                hasCustomPhoto = true
            } else if let existing = profile?.imageURL?.lastPathComponent {
                imageUri = existing
            } else {
                imageUri = ""
            }

            let response = try await client.putUsersMe(
                .init(body: .json(.init(
                    name: name,
                    birthday: birthday,
                    imageUri: imageUri
                )))
            )

            switch response {
            case .ok:
                await loadProfile()
            case .unauthorized(_):
                error = APIError.unauthorized
            default:
                print("❌ putUsersMe unexpected response: \(response)")
                error = APIError.unexpected
            }
        } catch {
            print("❌ updateProfile failed: \(error)")
            self.error = error
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.deleteUsersMe()
            switch response {
            case .ok:
                profile = nil
            case .unauthorized(_):
                error = APIError.unauthorized
            default:
                error = APIError.unexpected
            }
        } catch {
            print("❌ deleteAccount failed: \(error)")
            self.error = error
        }
    }

    private func uploadImage(_ data: Data) async throws -> String {
        let baseURL = try Servers.Server1.url()
        let uploadURL = baseURL.appendingPathComponent("uploads")

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jxl\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jxl\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let bodyText = String(data: responseData, encoding: .utf8) ?? "<binary>"
            print("❌ upload failed, status: \((response as? HTTPURLResponse)?.statusCode ?? -1), body: \(bodyText)")
            throw APIError.unexpected
        }

        struct UploadResponse: Decodable { let file: String }
        if let decoded = try? JSONDecoder().decode(UploadResponse.self, from: responseData) {
            return decoded.file
        }
        if let text = String(data: responseData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return text
        }
        print("❌ upload: couldn't parse response as JSON or plain text: \(responseData)")
        throw APIError.unexpected
    }
}

#if DEBUG
extension UserService {
    convenience init(previewProfile: UserProfile?) {
        self.init(client: Client(
            serverURL: URL(string: "https://example.com")!,
            transport: URLSessionTransport()
        ))
        self.profile = previewProfile
    }
}
#endif
