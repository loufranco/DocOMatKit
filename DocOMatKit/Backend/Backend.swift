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
    func authenticate(completion: () -> (), error: (NSError) -> ())
}

/// Defines Retrieval
public protocol BackendDocRetrieval {
    func get() -> Document
}

/// Defines Formatting
public protocol BackendDocFormatter {
    func formatAsHtml(doc: Document) -> String
}

/// An abstract factory to create objects you need to connect
/// to a documentation back-end.
public protocol BackendFactory {
    func makeAuth() -> BackendAuth
    func makeDocRetrieval() -> BackendDocRetrieval
    func makeDocFormatter() -> BackendDocFormatter
}