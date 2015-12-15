//
//  ConfigTests.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/14/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import XCTest
import DocOMatKit

class ConfigTests: XCTestCase {

    func testLoadPlist() {
        let config = PListConfig(name: "test-config", bundle: NSBundle(forClass: ConfigTests.self))
        guard let backendType = config.backendType() else {
            XCTFail("Expect a backend type")
            return
        }
        XCTAssertGreaterThan(backendType.characters.count, 0)
    }

}
