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
    func canHaveChildren() -> Bool
}

extension Referenceable {
    public func canHaveChildren() -> Bool {
        return false
    }
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

    public init(docRetrieval: BackendDocRetrieval, referenceName: String) {
        self.docRetrieval = docRetrieval
        self.referenceName = referenceName
    }
    
    public func get(reportResult: Result<Content>.Fn) {
        self.docRetrieval.get(self, reportResult: reportResult)
    }
}

public struct FolderReference: Referenceable {
    public let docRetrieval: BackendDocRetrieval
    public let referenceName: String
    
    public init(docRetrieval: BackendDocRetrieval, referenceName: String) {
        self.docRetrieval = docRetrieval
        self.referenceName = referenceName
    }
    
    public func get(reportResult: Result<Content>.Fn) {
        self.docRetrieval.getAsFolder(self, reportResult: reportResult)
    }
    
    public func canHaveChildren() -> Bool {
        return true
    }
}

public protocol Content {
    var title: String { get }
    var content: String { get }
    var reference: Referenceable { get }
    
    func getChildren(reportResult: Result<[Referenceable]>.Fn)
    func canHaveChildren() -> Bool
}

extension Content {
    public func canHaveChildren() -> Bool {
        return false
    }
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

public struct ErrorContent: Content {
    public let title: String
    public let content = ""
    public var reference: Referenceable
    
    public init(error: ErrorType, reference: Referenceable) {
        let nsError = error as NSError
        self.title = nsError.localizedDescription
        self.reference = reference
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
    
    public init(title: String, content: String, reference: Referenceable) {
        self.title = title
        self.content = content
        self.reference = reference
    }
    
    public func canHaveChildren() -> Bool {
        return true
    }
    
    public func getChildren(reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.Success([]))
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
    public let title: String
    public let content: String
    public let reference: Referenceable
    
    public init(content: String, reference: Referenceable) {
        self.content = content
        let contentLines = self.content.componentsSeparatedByString("\n")
        self.title = (contentLines.count > 0) ? contentLines[0] : ""
        self.reference = reference
    }
}

public struct UnknownFile: File {
    public let title: String
    public let content: String
    public let reference: Referenceable
    
    public init(title: String, content: String, reference: Referenceable) {
        self.title = title
        self.content = content
        self.reference = reference
    }
}
