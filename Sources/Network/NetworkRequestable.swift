//
//  NetworkRequestable.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

public protocol NetworkRequestable {
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String]) async throws -> T
}
