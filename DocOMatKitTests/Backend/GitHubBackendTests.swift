//
//  GitHubBackendTests.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/16/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import XCTest
import DocOMatKit


func XCTAssertResultSuccess<T>(_ result: Result<T>) {
    if case let .error(e) = result {
        XCTFail("Unexpected error: \(e)")
    }
}

class GitHubBackendTests: XCTestCase {
    
    var github: GitHubFactory!
    let config = [
        "type": "GitHub",
        "url": "https://api.github.com/repos/loufranco/DocOMatKit/contents",
        "base-path": "docs",
        "title": "Doc-o-Mat Kit",
    ]
    
    override func setUp() {
        let authConfig = PListConfig(name: "Auth/auth", bundle: Bundle(for: GitHubBackendTests.self)).dict("GitHub")
        github = GitHubFactory(config: ConfigWithDictionary(configDict: config as [String : AnyObject]), authConfig: authConfig)
    }
    
    func testPublicAuth() {
        let auth = github.makeAuth()
        var completes = false
        auth.authenticate { r in
            if case .success = r {
                completes = true
            }
        }
        XCTAssert(completes)
    }
    
    func checkRefList(_ list: [Referenceable]) -> Result<()> {
        XCTAssert(list.count > 0)
        for l in list {
            XCTAssert(l.referenceName.hasPrefix("docs/0"))
        }
        return .success(())
    }
    
    func checkDocTitle(_ doc: Content) -> Result<()> {
        XCTAssertNotEqual(doc.title, "")
        return .success(())
    }

    func testGetList() {
        let auth = github.makeAuth()
        var completes = false
        auth.authenticate { docRetrievalResult in
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                docRetrieval.getList { (listResult) -> () in
                    XCTAssertResultSuccess(listResult |> self.checkRefList)
                    completes = true
                }
                return .success(())
            }
        }
        XCTAssert(completes)
    }
    
    func testGetRef() {
        let auth = github.makeAuth()
        var completes = false
        auth.authenticate { docRetrievalResult in
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                let ref = ContentReference(docRetrieval: docRetrieval, referenceName: "docs/03-about-the-license.md")
                ref.get() { doc in
                    XCTAssertResultSuccess(doc |> self.checkDocTitle)
                    completes = true
                }
                return .success(())
            }
        }
        XCTAssert(completes)
    }
}
