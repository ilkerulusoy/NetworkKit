//
//  MockNetworkRequestable.swift
//  Network
//
//  Created by ilker on 17.10.2024.
//
import Foundation

class MockNetworkRequestable: NetworkRequestable {
    var requestCallCount = 0
    var lastHeaders: [String: String] = [:]
    var shouldSucceed = true
    
    func request<T>(_ endpoint: String, method: HTTPMethod, body: [String : Any]?, responseType: T.Type, headers: [String : String]) async throws -> T where T : Decodable {
        requestCallCount += 1
        lastHeaders = headers
        
        if shouldSucceed {
            if responseType == TestItem.self {
                return TestItem(id: 1, name: "Test Item") as! T
            }
            throw NetworkError.decodingError
        } else {
            throw NetworkError.custom("Mock error")
        }
    }
}
