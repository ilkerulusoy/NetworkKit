//
//  RetryDecorator.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

class RetryDecorator: NetworkRequestable {
    private let wrapped: NetworkRequestable
    
    init(_ wrapped: NetworkRequestable) {
        self.wrapped = wrapped
    }
    
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String] = [:]) async throws -> T {
        var lastError: Error?
        
        do {
            return try await wrapped.request(endpoint, method: method, body: body, responseType: responseType, headers: headers)
        } catch {
            lastError = error
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return try await wrapped.request(endpoint, method: method, body: body, responseType: responseType, headers: headers)
        }
        
        throw lastError ?? NetworkError.custom("Retry failed")
    }
}
