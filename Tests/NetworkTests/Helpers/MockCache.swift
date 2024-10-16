//
//  MockCache.swift
//  Network
//
//  Created by ilker on 17.10.2024.
//
import Foundation

class MockCache: NSCache<NSString, AnyObject> {
    var setCallCount = 0
    var getCallCount = 0
    
    override func setObject(_ obj: AnyObject, forKey key: NSString) {
        setCallCount += 1
        super.setObject(obj, forKey: key)
    }
    
    override func object(forKey key: NSString) -> AnyObject? {
        getCallCount += 1
        return super.object(forKey: key)
    }
}
