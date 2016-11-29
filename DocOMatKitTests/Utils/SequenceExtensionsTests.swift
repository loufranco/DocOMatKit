//
//  SequenceExtensionsTests.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/31/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import XCTest

class SequenceExtensionsTests: XCTestCase {

    func testDropWhileEmpty() {
        XCTAssertEqual(String("".characters.dropWhile { _ in false }), "")
        XCTAssertEqual(String("".characters.dropWhile { _ in true }), "")
        XCTAssertEqual(String("abcde".characters.dropWhile { _ in true }), "")
    }

    func testDropWhile() {
        XCTAssertEqual(String("abcd".characters.dropWhile { $0 == "a" }), "bcd")
        XCTAssertEqual(String("abcd".characters.dropWhile { $0 != "d" }), "d")
        XCTAssertEqual(String("abacad".characters.dropWhile { $0 == "a" }), "bacad")
    }

    func testTakeWhileEmpty() {
        XCTAssertEqual(String("".characters.takeWhile { _ in false }), "")
        XCTAssertEqual(String("".characters.takeWhile { _ in true }), "")
        XCTAssertEqual(String("abcde".characters.takeWhile { _ in false }), "")
    }

    func testTakeWhile() {
        XCTAssertEqual(String("abcd".characters.takeWhile { _ in true }), "abcd")
        XCTAssertEqual(String("abcd".characters.takeWhile { $0 != "b" }), "a")
        XCTAssertEqual(String("abcd".characters.takeWhile { $0 == "a" }), "a")
    }

}
