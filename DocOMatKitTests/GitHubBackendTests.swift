//
//  GitHubBackendTests.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/16/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import XCTest
import DocOMatKit


class GitHubBackendTests: XCTestCase {
    
    var github: GitHubFactory!
    
    override func setUp() {
        github = GitHubFactory(rootUrl: NSURL(string: "https://api.github.com/repos/loufranco/DocOMatKit/contents/docs")!)
    }
    
    func testPublicAuth() {
        let auth = github.makeAuth()
        var completes = false
        auth.authenticate({ (_) -> () in
            completes = true
        }) { (_) -> () in
            XCTFail("should not have an error")
        }
        XCTAssert(completes)
    }
    
    
    func testGetList() {
        let auth = github.makeAuth()
        auth.authenticate({ (docRetrieval) -> () in
            docRetrieval.getList()
        }, error: nil)
    }

}
