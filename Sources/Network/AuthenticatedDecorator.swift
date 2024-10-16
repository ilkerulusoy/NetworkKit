//
//  AuthenticatedDecorator.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

class AuthenticatedDecorator: NetworkRequestable {
    private let wrapped: NetworkRequestable
    private let tokenProvider: () -> String?
    private let needsAuth: (String) -> Bool
    
    init(_ wrapped: NetworkRequestable, tokenProvider: @escaping () -> String?, needsAuth: @escaping (String) -> Bool) {
        self.wrapped = wrapped
        self.tokenProvider = tokenProvider
        self.needsAuth = needsAuth
    }
    
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String] = [:]) async throws -> T {
        var newHeaders = headers
        if needsAuth(endpoint), let token = tokenProvider() {
            newHeaders["Authorization"] = "Bearer \(token)"
        }
        return try await wrapped.request(endpoint, method: method, body: body, responseType: responseType, headers: newHeaders)
    }
}
