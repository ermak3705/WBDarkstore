//
//  APIClient.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 03.07.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APIClientFactory {
    static func makeClient(token: String) throws -> Client {
       try Client(
        serverURL: Servers.Server1.url(),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware(token: token)])
    }
}

