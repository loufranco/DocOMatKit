//
//  Config.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/14/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// A protocol that defines what a configuration must have
public protocol Config {
    func string(key: String?) -> String?
    func dict(key: String?) -> Config?
    func keyCount() -> Int
    func backends() -> Config?
}

/// The default keys for config objects.
extension Config {
    public func backends() -> Config? {
        return dict("backends")
    }
}

/// A protocol for any configuration that just uses a dictionary.
public protocol DictConfig: Config {
    var configDict: [String: AnyObject] { get }
}

/// A concrete configuration type that must be initialized with a dictionary.
public struct ConfigWithDictionary: DictConfig {
    public let configDict: [String: AnyObject]
}

/// The default behavior of any config that uses a dictionary
extension DictConfig {
    public func dict(key: String?) -> Config? {
        guard let key = key else { return nil }
        if let d = (configDict[key] as? [String: AnyObject]) {
            return ConfigWithDictionary(configDict: d)
        }
        return nil
    }
    
    public func string(key: String?) -> String? {
        guard let key = key else { return nil }
        return configDict[key] as? String
    }
    
    public func keyCount() -> Int {
        return configDict.keys.count
    }
}

/// A config that can load itself from a .plist file in a bundle
public struct PListConfig: DictConfig {
    public var configDict: [String: AnyObject]
}

/// PListConfig functionality not defined in the protocols it conforms to.
public extension PListConfig {
    init(name: String, bundle: NSBundle) {
        if let path = bundle.pathForResource(name, ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                configDict = dict
        } else {
            configDict = [:]
        }
    }
}