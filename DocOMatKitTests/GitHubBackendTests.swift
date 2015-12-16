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
        github = GitHubFactory(rootUrl: NSURL(string: "https://github.com/loufranco/DocOMatKit")!)
    }

}
