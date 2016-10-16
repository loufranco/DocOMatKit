//
//  Backend.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// Defines Authentication
public protocol BackendAuth {
    func authenticate(_ reportResult: Result<BackendDocRetrieval>.Fn)
}

/// An authentication object that always succeeds.
public struct NullAuth: BackendAuth {
    let docRetrieval: BackendDocRetrieval
    
    public init(docRetrieval: BackendDocRetrieval) {
        self.docRetrieval = docRetrieval
    }
    
    public func authenticate(_ reportResult: Result<BackendDocRetrieval>.Fn) {
        reportResult(.success(self.docRetrieval))
    }
}

/// Defines Retrieval
public protocol BackendDocRetrieval {
    func getList(_ reportResult: @escaping Result<[Referenceable]>.Fn)
    func getList(_ ref: Referenceable?, reportResult: @escaping Result<[Referenceable]>.Fn)
    func get(_ ref: Referenceable, reportResult: @escaping Result<Content>.Fn)
    func getAsFolder(_ ref: Referenceable, reportResult: @escaping Result<Content>.Fn)
}

/// Defines Formatting
public protocol BackendDocFormatter {
    func formatAsHtml(_ doc: File) -> String
}

/// An abstract factory to create objects you need to connect
/// to a documentation back-end.
public protocol BackendFactory {
    func makeAuth() -> BackendAuth
    func makeDocFormatter() -> BackendDocFormatter
}

/// Create a factory from a configuration
public func makeBackendFactory(_ config: Config?, authConfig: Config?) -> BackendFactory? {
    guard let type = config?.string("type") else {
        return nil
    }
    
    switch (type) {
    case "GitHub":
        return GitHubFactory(config: config, authConfig: authConfig)
    default:
        return nil
    }
}
