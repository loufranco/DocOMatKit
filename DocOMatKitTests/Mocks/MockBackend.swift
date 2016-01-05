//
//  MockBackend.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/4/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import Foundation
import DocOMatKit

struct MockDocFormatter: BackendDocFormatter {
    func formatAsHtml(doc: File) -> String {
        return doc.content
    }
}

struct MockDocRetrieval: BackendDocRetrieval {
    func getList(reportResult: Result<[Referenceable]>.Fn) {
        getList(nil, reportResult: reportResult)
    }
    
    func getList(ref: Referenceable?, reportResult: Result<[Referenceable]>.Fn) {
        switch (ref?.referenceName) {
        case .None:
            reportResult(Result<[Referenceable]>( [
                    FolderReference(docRetrieval: self, referenceName: "folder"),
                    ContentReference(docRetrieval: self, referenceName: "file-1")
                ]))
            return
        case .Some("folder"):
            reportResult(Result<[Referenceable]>([
                ContentReference(docRetrieval: self, referenceName: "folder-file-1"),
                ContentReference(docRetrieval: self, referenceName: "folder-file-2")
                ]))
            return
        default:
            reportResult(Result<[Referenceable]>(nil))
        }
    }
    
    func get(ref: Referenceable, reportResult: Result<Content>.Fn) {
        reportResult(Result<Content>(UnknownFile(title: ref.referenceName, content: ref.referenceName, reference: ref)))
    }
    
    func getAsFolder(ref: Referenceable, reportResult: Result<Content>.Fn) {
        reportResult(Result<Content>(ContentFolder(title: ref.referenceName, content: ref.referenceName, reference: ref)))
    }
}

struct MockBackendFactory: BackendFactory {
    func makeAuth() -> BackendAuth {
        return NullAuth(docRetrieval: MockDocRetrieval())
    }
    
    func makeDocFormatter() -> BackendDocFormatter {
        return MockDocFormatter()
    }
}