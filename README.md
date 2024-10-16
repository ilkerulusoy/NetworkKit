# Swift Network Library

A flexible and extensible Swift networking library built with the decorator pattern. This library provides a robust solution for handling HTTP requests with support for:

- Authentication
- Caching
- Automatic retries
- Fallback mechanisms

Easily chainable decorators allow you to customize your network stack to fit your specific needs. Built with Swift concurrency, this library offers a modern, efficient approach to networking in iOS and macOS applications.

## Key Features:
- 🔒 Seamless authentication integration
- 💾 Efficient caching for improved performance
- 🔄 Configurable retry logic for handling transient failures
- 🔀 Fallback support for robust error handling
- 🧪 Highly testable with provided mocks

Perfect for projects requiring a customizable and reliable networking solution.

## Core Components

### NetworkRequestable Protocol

The base protocol for all network requests.

```swift
protocol NetworkRequestable {
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod,
                               body: [String: Any]?,
                               responseType: T.Type,
                               headers: [String: String]) async throws -> T
}
```

### BaseNetworkRequestable

The fundamental implementation of `NetworkRequestable`.

## Decorators

### AuthenticatedDecorator

Adds authentication to requests.

```swift
func authenticated(tokenProvider: @escaping () -> String?, 
                   needsAuth: @escaping (String) -> Bool) -> NetworkRequestable
```

### CacheDecorator

Implements caching for requests.

```swift
func cached(cache: NSCache<NSString, AnyObject> = NSCache<NSString, AnyObject>()) -> NetworkRequestable
```

### RetryDecorator

Adds retry functionality to requests.

```swift
func retry() -> NetworkRequestable
func retry(maxAttempts: Int) -> NetworkRequestable
```

### FallbackDecorator

Provides a fallback mechanism for failed requests.

```swift
func fallback(provider: @escaping () -> NetworkRequestable) -> NetworkRequestable
```

## Usage

Create a network requestable object with desired decorators:

```swift
let networkRequestable = BaseNetworkRequestable(baseURL: baseURL)
    .authenticated(tokenProvider: { UserDefaults.standard.string(forKey: "authToken") },
                   needsAuth: { $0.contains("secure") })
    .cached()
    .retry()
    .fallback(provider: { BaseNetworkRequestable(baseURL: "https://fallback-api.example.com") })
```

Make a request:

```swift
let result: SomeDecodable = try await networkRequestable.request(
    "/endpoint",
    method: .get,
    body: nil,
    responseType: SomeDecodable.self,
    headers: [:]
)
```

## Testing

Use `MockNetworkRequestable` and `MockCache` for unit testing:

```swift
let mockRequestable = MockNetworkRequestable()
let mockCache = MockCache()

// Configure and use these mocks in your tests
```

## Error Handling

The library uses a custom `NetworkError` enum for error cases:

```swift
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case httpError(statusCode: Int)
    case unauthorized
    case custom(String)
}
```

Handle these errors appropriately in your application code.
