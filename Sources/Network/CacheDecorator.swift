//
//  CacheDecorator.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

class CacheDecorator: NetworkRequestable {
    private let wrapped: NetworkRequestable
    private let cache: NSCache<NSString, AnyObject>
    
    init(_ wrapped: NetworkRequestable, cache: NSCache<NSString, AnyObject> = NSCache<NSString, AnyObject>()) {
        self.wrapped = wrapped
        self.cache = cache
    }
    
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String] = [:]) async throws -> T {
        let cacheKey = NSString(string: "\(method.rawValue)_\(endpoint)")
        
        if let cachedResponse = cache.object(forKey: cacheKey) as? T {
            return cachedResponse
        }
        
        let response = try await wrapped.request(endpoint, method: method, body: body, responseType: responseType, headers: headers)
        cache.setObject(response as AnyObject, forKey: cacheKey)
        return response
    }
}
