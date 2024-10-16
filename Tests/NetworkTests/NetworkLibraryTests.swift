//
//  NetworkLibraryTests.swift
//  Network
//
//  Created by ilker on 17.10.2024.
//


import Testing
@testable import NetworkKit // Replace with your actual module name

struct NetworkLibraryTests {
    @Test
    func testAuthenticatedDecorator() async throws {
        let mockRequestable = MockNetworkRequestable()
        let authenticatedRequestable = mockRequestable.authenticated(
            tokenProvider: { "test_token" },
            needsAuth: { $0.contains("secure") }
        )
        
        let _: TestItem = try await authenticatedRequestable.request(
            "/secure-endpoint",
            method: .get,
            body: nil,
            responseType: TestItem.self,
            headers: [:]
        )
        
        #expect(mockRequestable.requestCallCount == 1)
        #expect(mockRequestable.lastHeaders["Authorization"] == "Bearer test_token")
    }
    
    @Test
    func testCachedDecorator() async throws {
        let mockRequestable = MockNetworkRequestable()
        let mockCache = MockCache()
        let cachedRequestable = mockRequestable.cached(cache: mockCache)
        
        // First request
        let _: TestItem = try await cachedRequestable.request(
            "/test-endpoint",
            method: .get,
            body: nil,
            responseType: TestItem.self,
            headers: [:]
        )
        
        #expect(mockRequestable.requestCallCount == 1)
        #expect(mockCache.setCallCount == 1)
        
        // Second request (should be cached)
        let _: TestItem = try await cachedRequestable.request(
            "/test-endpoint",
            method: .get,
            body: nil,
            responseType: TestItem.self,
            headers: [:]
        )
        
        #expect(mockRequestable.requestCallCount == 1) // Still 1, as it should use cache
        #expect(mockCache.getCallCount == 1)
    }
    
    @Test
    func testRetryDecorator() async throws {
        let mockRequestable = MockNetworkRequestable()
        mockRequestable.shouldSucceed = false
        let retryRequestable = mockRequestable.retry()
        
        do {
            let _: TestItem = try await retryRequestable.request(
                "/test-endpoint",
                method: .get,
                body: nil,
                responseType: TestItem.self,
                headers: [:]
            )
            Issue.record("Expected an error, but request succeeded")
        } catch {
            #expect(mockRequestable.requestCallCount > 1)
        }
    }
    
    @Test
    func testFallbackDecorator() async throws {
        let mockRequestable = MockNetworkRequestable()
        mockRequestable.shouldSucceed = false
        let fallbackMockRequestable = MockNetworkRequestable()
        let fallbackRequestable = mockRequestable.fallback(provider: { fallbackMockRequestable })
        
        let _: TestItem = try await fallbackRequestable.request(
            "/test-endpoint",
            method: .get,
            body: nil,
            responseType: TestItem.self,
            headers: [:]
        )
        
        #expect(mockRequestable.requestCallCount == 1)
        #expect(fallbackMockRequestable.requestCallCount == 1)
    }
    
    @Test
    func testFullDecoratorChain() async throws {
        let baseURL = "https://api.example.com"
        let mockRequestable = MockNetworkRequestable()
        let mockCache = MockCache()
        
        let decoratedRequestable = mockRequestable
            .authenticated(tokenProvider: { "test_token" }, needsAuth: { $0.contains("secure") })
            .cached(cache: mockCache)
            .retry()
            .fallback(provider: { MockNetworkRequestable() })
        
        let _: TestItem = try await decoratedRequestable.request(
            "/secure-endpoint",
            method: .get,
            body: nil,
            responseType: TestItem.self,
            headers: [:]
        )
        
        #expect(mockRequestable.requestCallCount == 1)
        #expect(mockRequestable.lastHeaders["Authorization"] == "Bearer test_token")
        #expect(mockCache.setCallCount == 1)
    }
}
