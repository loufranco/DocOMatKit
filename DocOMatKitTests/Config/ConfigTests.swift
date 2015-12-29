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
        guard let backends = config.backends() else {
            XCTFail("Expect a backend")
            return
        }
        XCTAssertGreaterThan(backends.keyCount(), 0)
    }

}
