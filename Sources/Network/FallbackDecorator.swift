//
//  FallbackDecorator.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

class FallbackDecorator: NetworkRequestable {
    private let wrapped: NetworkRequestable
    private let fallbackProvider: () -> NetworkRequestable
    
    init(_ wrapped: NetworkRequestable, fallbackProvider: @escaping () -> NetworkRequestable) {
        self.wrapped = wrapped
        self.fallbackProvider = fallbackProvider
    }
    
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String] = [:]) async throws -> T {
        do {
            return try await wrapped.request(endpoint, method: method, body: body, responseType: responseType, headers: headers)
        } catch {
            let fallbackRequestable = fallbackProvider()
            return try await fallbackRequestable.request(endpoint, method: method, body: body, responseType: responseType, headers: headers)
        }
    }
}
