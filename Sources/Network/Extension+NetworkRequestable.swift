//
//  Extension+NetworkRequestable.swift
//  Network
//
//  Created by ilker on 16.10.2024.
//
import Foundation

extension NetworkRequestable {
    public func retry() -> NetworkRequestable {
        return RetryDecorator(self)
    }
    
    public func retry(maxAttempts: Int) -> NetworkRequestable {
        if maxAttempts <= 0 {
            return self
        } else if maxAttempts == 1 {
            return self.retry()
        } else {
            var retry = self.retry()
            for _ in 1..<maxAttempts-1 {
                retry = retry.retry()
            }
            return retry
        }
    }
    
    public func authenticated(tokenProvider: @escaping () -> String?, needsAuth: @escaping (String) -> Bool) -> NetworkRequestable {
        return AuthenticatedDecorator(self, tokenProvider: tokenProvider, needsAuth: needsAuth)
    }
    
    public func cached(cache: NSCache<NSString, AnyObject> = NSCache<NSString, AnyObject>()) -> NetworkRequestable {
        return CacheDecorator(self, cache: cache)
    }
    
    public func fallback(provider: @escaping () -> NetworkRequestable) -> NetworkRequestable {
        return FallbackDecorator(self, fallbackProvider: provider)
    }
}
