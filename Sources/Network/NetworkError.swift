//
//  NetworkError.swift
//  Network
//
//  Created by ilker on 17.10.2024.
//
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case httpError(statusCode: Int)
    case unauthorized
    case custom(String)
}
