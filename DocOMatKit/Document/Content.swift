//
//  Content.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/15/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation


public protocol Referenceable {
    var referenceName: String { get }
    func get(reportResult: Result<Content>.Fn)
}

public struct ContentReference: Referenceable {
    public let docRetrieval: BackendDocRetrieval
    public let referenceName: String

    public init(docRetrieval: BackendDocRetrieval,referenceName: String) {
        self.docRetrieval = docRetrieval
        self.referenceName = referenceName
    }
    
    public func get(reportResult: Result<Content>.Fn) {
        self.docRetrieval.get(self, reportResult: reportResult)
    }
}

public protocol Content {
    var title: String { get }
    var content: String { get }
    func getChildren() -> [Referenceable]
}

public struct EmptyContent: Content {
    public let title = ""
    public let content = ""
    public func getChildren() -> [Referenceable] {
        return []
    }
}

/// Folders
public struct ContentFolder: Content {
    public let title: String
    public let content: String
    public func getChildren() -> [Referenceable] {
        return []
    }
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

/// Defines documents
public protocol Document: Content {
    
}

public extension Document {
    public func getChildren() -> [Referenceable] {
        return []
    }
}

public struct MarkdownDocument: Document {
    public let content: String
    public let title: String
    
    public init(content: String) {
        self.content = content
        let contentLines = self.content.componentsSeparatedByString("\n")
        self.title = (contentLines.count > 0) ? contentLines[0] : ""
    }
}