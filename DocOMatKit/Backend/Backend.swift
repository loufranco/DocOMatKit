//
//  Backend.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public enum DocOMatErrorDomain: String {
    case Auth = "DocOMatAuthErrorDomain"
}

public enum DocOMatAuthCode: Int {
    case Failed = -1
}


/// Defines Authentication
public protocol BackendAuth {
    func authenticate(completion: ((docRetrieval: BackendDocRetrieval) -> ())?, error: ((NSError) -> ())?)
}

/// An authentication object that always succeeds.
public struct NullAuth: BackendAuth {
    let docRetrieval: BackendDocRetrieval
    
    init(docRetrieval: BackendDocRetrieval) {
        self.docRetrieval = docRetrieval
    }
    
    public func authenticate(completion: ((docRetrieval: BackendDocRetrieval) -> ())?, error: ((NSError) -> ())?) {
        completion?(docRetrieval: docRetrieval)
    }
}

/// Defines Retrieval
public protocol BackendDocRetrieval {
    func getList() -> [Content]
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