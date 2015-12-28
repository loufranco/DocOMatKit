//
//  Document.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/15/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public protocol Content {
    var title: String { get }
}

public struct EmptyContent: Content {
    public let title = ""
}

public protocol Referenceable {
    var referenceName: String { get }
}

public struct ContentReference: Referenceable {
    public let referenceName: String
    public init(referenceName: String) {
        self.referenceName = referenceName
    }
}

/// Defines documents
public protocol Document: Content {
    
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