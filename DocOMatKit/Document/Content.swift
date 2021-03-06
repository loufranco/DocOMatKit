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
    func title() -> String
    func get(_ reportResult: @escaping Result<Content>.Fn)
    func canHaveChildren() -> Bool
}

extension Referenceable {

    public func title() -> String {
        return URL(string: self.referenceName)?.lastPathComponent ?? self.referenceName
    }

    public func canHaveChildren() -> Bool {
        return false
    }

}

public struct NullContentReference: Referenceable {
    public let referenceName: String = ""

    public func get(_ reportResult: @escaping Result<Content>.Fn) {
        reportResult(Result<Content>.success(EmptyContent()))
    }

}

public struct ContentReference: Referenceable {
    public let docRetrieval: BackendDocRetrieval
    public let referenceName: String

    public init(docRetrieval: BackendDocRetrieval, referenceName: String) {
        self.docRetrieval = docRetrieval
        self.referenceName = referenceName
    }

    public func get(_ reportResult: @escaping Result<Content>.Fn) {
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

    public func get(_ reportResult: @escaping Result<Content>.Fn) {
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

    func getChildren(_ reportResult: Result<[Referenceable]>.Fn)
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

    public func getChildren(_ reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.success([]))
    }

}

public struct ErrorContent: Content {
    public let title: String
    public let content = ""
    public var reference: Referenceable

    public init(error: Error, reference: Referenceable) {
        let nsError = error as NSError
        self.title = nsError.localizedDescription
        self.reference = reference
    }

    public func getChildren(_ reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.success([]))
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

    public func getChildren(_ reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.success([]))
    }

}

/// Defines documents
public protocol File: Content {

}

public extension File {

    public func getChildren(_ reportResult: Result<[Referenceable]>.Fn) {
        reportResult(Result<[Referenceable]>.success([]))
    }

}

public struct MarkdownDocument: File {
    public let title: String
    public let content: String
    public let reference: Referenceable

    static func titleFromContent(_ content: String) -> String {
        return String(content.characters.dropWhile { ["#", " "].contains($0) }.takeWhile { $0 != "\n" })
    }

    public init(content: String, reference: Referenceable) {
        self.content = content
        self.title = MarkdownDocument.titleFromContent(content)
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
