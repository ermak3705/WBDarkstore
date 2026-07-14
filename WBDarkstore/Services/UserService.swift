//
//  UserService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class UserService {
    private let client: Client

    private(set) var profile: UserProfile?
    private(set) var isLoading = false
    private(set) var error: Error?

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
}
