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

public struct NullContentReference: Referenceable {
    public let referenceName: String = ""
    public func get(reportResult: Result<Content>.Fn) {
        reportResult(Result<Content>.Success(EmptyContent()))
    }
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
    var reference: Referenceable { get }
    
    func getChildren(reportResult: Result<[Referenceable]>.Fn)
}

public struct EmptyContent: Content {
    public let title = ""
    public let content = ""
    public var reference: Referenceable
    
    public init() {
        self.reference = NullContentReference()
    }
    
    public func getChildren(reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.Success([]))
    }
}

/// Folders
public struct ContentFolder: Content {
    public let title: String
    public let content: String
    public let reference: Referenceable
    
    public func getChildren(reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.Success([]))
    }
    
    public init(title: String, content: String, reference: Referenceable) {
        self.title = title
        self.content = content
        self.reference = reference
    }
}

/// Defines documents
public protocol File: Content {
    
}

public extension File {
    public func getChildren(reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.Success([]))
    }
}

public struct MarkdownDocument: File {
    public let content: String
    public let title: String
    public let reference: Referenceable
    
    public init(content: String, reference: Referenceable) {
        self.content = content
        let contentLines = self.content.componentsSeparatedByString("\n")
        self.title = (contentLines.count > 0) ? contentLines[0] : ""
        self.reference = reference
    }
}