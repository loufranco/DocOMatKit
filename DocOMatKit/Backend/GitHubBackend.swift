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
    public func authenticate(completion: ((docRetrieval: BackendDocRetrieval) -> ())?, error: ((NSError) -> ())?) {
        error?(NSError(domain: DocOMatErrorDomain.Auth.rawValue, code: DocOMatAuthCode.Failed.rawValue, userInfo: nil))
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
    public let rootUrl: NSURL
    
    public init(rootUrl: NSURL) {
        self.rootUrl = rootUrl
    }
    
    public func getList() -> [Content] {
        return []
    }
}

public struct GitHubFactory: BackendFactory {
    
    public let rootUrl: NSURL
    
    public init(rootUrl: NSURL) {
        self.rootUrl = rootUrl
    }
    
    public func makeAuth() -> BackendAuth {
        return NullAuth(docRetrieval: GitHubDocRetrieval(rootUrl: rootUrl))
    }
    
    public func makeDocFormatter() -> BackendDocFormatter {
        return GitHubDocFormatter()
    }
    
    public func makeDocRetrieval() -> BackendDocRetrieval {
        return GitHubDocRetrieval(rootUrl: rootUrl)
    }
}
