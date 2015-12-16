//
//  GitHubBackend.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/16/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// Defines the types needed to get documentation from GitHub

struct GitHubAuth: BackendAuth {
    func authenticate(completion: () -> (), error: (NSError) -> ()) {
        
    }
}

struct GitHubDocFormatter: BackendDocFormatter {
    func formatAsHtml(doc: Document) -> String {
        return ""
    }
}

struct GitHubDocument: Document {
    
}

struct GitHubDocRetrieval: BackendDocRetrieval {
    func get() -> Document {
        return GitHubDocument()
    }
}

struct GitHubFactory: BackendFactory {
    func makeAuth() -> BackendAuth {
        return GitHubAuth()
    }
    
    func makeDocFormatter() -> BackendDocFormatter {
        return GitHubDocFormatter()
    }
    
    func makeDocRetrieval() -> BackendDocRetrieval {
        return GitHubDocRetrieval()
    }
}
