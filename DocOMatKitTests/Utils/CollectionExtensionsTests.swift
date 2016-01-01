//
//  CollectionExtensionsTests.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/31/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import XCTest

class CollectionExtensionsTests: XCTestCase {

    func testDropWhileEmpty() {
        XCTAssertEqual(String("".characters.dropWhile({ _ in false })), "")
        XCTAssertEqual(String("".characters.dropWhile({ _ in true })), "")
        XCTAssertEqual(String("abcde".characters.dropWhile({ _ in true })), "")
    }

    func testDropWhile() {
        XCTAssertEqual(String("abcd".characters.dropWhile({ $0 == "a" })), "bcd")
        XCTAssertEqual(String("abcd".characters.dropWhile({ $0 != "d" })), "d")
    }

    func testTakeUntilEmpty() {
        XCTAssertEqual(String("".characters.takeUntil({ _ in false })), "")
        XCTAssertEqual(String("".characters.takeUntil({ _ in true })), "")
        XCTAssertEqual(String("abcde".characters.takeUntil({ _ in true })), "")
    }
    
    func testTakeUntil() {
        XCTAssertEqual(String("abcd".characters.takeUntil({ $0 == "b" })), "a")
        XCTAssertEqual(String("abcd".characters.takeUntil({ $0 != "a" })), "a")
    }
}
