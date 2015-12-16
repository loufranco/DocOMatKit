//
//  GitHubBackend.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/16/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// Defines the types needed to get documentation from GitHub

public struct GitHubPrivateAuth: BackendAuth {
    public func authenticate(completion: () -> (), error: (NSError) -> ()) {
        
    }
}

public struct GitHubPublicAuth: BackendAuth {
    public func authenticate(completion: () -> (), error: (NSError) -> ()) {
        completion()
    }
}


public struct GitHubDocFormatter: BackendDocFormatter {
    public func formatAsHtml(doc: Document) -> String {
        return ""
    }
}

public struct GitHubDocument: Document {
    
}

public struct GitHubDocRetrieval: BackendDocRetrieval {
    public func get() -> Document {
        return GitHubDocument()
    }
}

public struct GitHubFactory: BackendFactory {
    
    public let rootUrl: NSURL
    
    public init(rootUrl: NSURL) {
        self.rootUrl = rootUrl
    }
    
    public func makeAuth() -> BackendAuth {
        return GitHubPublicAuth()
    }
    
    public func makeDocFormatter() -> BackendDocFormatter {
        return GitHubDocFormatter()
    }
    
    public func makeDocRetrieval() -> BackendDocRetrieval {
        return GitHubDocRetrieval()
    }
}
