//
//  Backend.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// Defines Authentication
protocol BackendAuth {
    func authenticate(completion: () -> (), error: (NSError) -> ())
}

/// Defines Retrieval
protocol BackendDocRetrieval {
    func get() -> Document
}

/// Defines Formatting
protocol BackendDocFormatter {
    func formatAsHtml(doc: Document) -> String
}

/// An abstract factory to create objects you need to connect
/// to a documentation back-end.
protocol BackendFactory {
    func makeAuth() -> BackendAuth
    func makeDocRetrieval() -> BackendDocRetrieval
    func makeDocFormatter() -> BackendDocFormatter
}