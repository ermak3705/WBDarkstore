//
//  AddressService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 26.08.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@Observable
final class AddressService {
    private let client: Client

    private(set) var addresses: [Address] = []
    private(set) var isLoading = false
    var error: Error?

    var selectedAddressID: String?

    init(client: Client) {
        self.client = client
    }

    func loadAddresses() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.getAddresses()
            switch response {
            case .ok(let okResponse):
                let items = try okResponse.body.json
                addresses = items.compactMap { item -> Address? in
                    guard let id = item.value2.id else { return nil }
                    return Address(
                        id: id,
                        addressLine: item.value1.addressLine,
                        coordinates: item.value1.coordinates,
                        floor: item.value1.floor,
                        entrance: item.value1.entrance,
                        intercomCode: item.value1.intercomCode,
                        comment: item.value1.comment
                    )
                }
                if selectedAddressID == nil {
                    selectedAddressID = addresses.first?.id
                }
            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
    }

    @discardableResult
    func add(_ address: Address) async -> Bool {
        error = nil
        do {
            let response = try await client.postAddresses(
                body: .json(.init(
                    coordinates: address.coordinates,
                    addressLine: address.addressLine,
                    floor: address.floor,
                    entrance: address.entrance,
                    intercomCode: address.intercomCode,
                    comment: address.comment
                ))
            )
            switch response {
            case .ok:
                await loadAddresses()
                return true
            case .badRequest(_):
                error = APIError.unexpected
            case .unauthorized(_):
                error = APIError.unauthorized
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
        return false
    }

    @discardableResult
    func update(_ address: Address) async -> Bool {
        error = nil
        do {
            let response = try await client.putAddressesId(
                path: .init(id: address.id),
                body: .json(.init(
                    coordinates: address.coordinates,
                    addressLine: address.addressLine,
                    floor: address.floor,
                    entrance: address.entrance,
                    intercomCode: address.intercomCode,
                    comment: address.comment
                ))
            )
            switch response {
            case .ok:
                await loadAddresses()
                return true
            case .badRequest(_):
                error = APIError.unexpected
            case .unauthorized(_):
                error = APIError.unauthorized
            case .notFound(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
        return false
    }

    @discardableResult
    func delete(_ address: Address) async -> Bool {
        error = nil
        do {
            let response = try await client.deleteAddressesId(path: .init(id: address.id))
            switch response {
            case .ok:
                addresses.removeAll { $0.id == address.id }
                if selectedAddressID == address.id {
                    selectedAddressID = addresses.first?.id
                }
                return true
            case .unauthorized(_):
                error = APIError.unauthorized
            case .notFound(_):
                error = APIError.unexpected
            case .default(statusCode: _, _):
                error = APIError.unexpected
            }
        } catch {
            self.error = error
        }
        return false
    }
}
