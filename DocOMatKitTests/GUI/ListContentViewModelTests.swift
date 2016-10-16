//
//  ListContentViewModelTests.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/4/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import XCTest
import DocOMatKit


class ListContentViewModelTests: XCTestCase, DocListViewModelDelegate, DocViewCoordinator {
    var lastError: NSError? = nil
    var lastVM: DocListViewModelable? = nil
    var lastDoc: Content? = nil
    var showDocCalled = false
    var docListVM: DocListViewModelable? = nil
    
    override func setUp() {
        super.setUp()
        
        self.lastError = nil
        self.lastVM = nil
        self.lastDoc = nil
        
        docListVM = DocListViewModel(title: "", factory: MockBackendFactory(), baseReference: nil)
        docListVM?.connect(delegate: self)
        docListVM?.connect(coordinator: self)
    }
    
    func testGetList() {
        XCTAssertEqual(docListVM?.docCount(), 2)
        XCTAssertEqual(docListVM?.docTitle(0), "folder")
        XCTAssertTrue(docListVM?.docCanHaveChildren(0) ?? false)
        XCTAssertNil(self.lastError)
    }
    
    func testNavigateFolder() {
        docListVM?.docSelected(0)
        XCTAssertNotNil(self.lastVM)
        self.lastVM?.connect(delegate: self)
        XCTAssertEqual(self.lastVM?.docCount(), 2)
        XCTAssertEqual(self.lastVM?.docTitle(0), "folder-file-1")
        XCTAssertFalse(self.lastVM?.docCanHaveChildren(0) ?? true)
        XCTAssertNil(self.lastError)
    }
    
    func testShowDoc() {
        docListVM?.docSelected(1)
        XCTAssertNil(self.lastVM)
        XCTAssertNotNil(self.lastDoc)
        XCTAssertNil(self.lastError)
    }
    
    /// DocListViewModelDelegate
    
    func reloadData() {
        
    }
    
    func reloadRow(_ row: Int) {
        
    }
    
    func reportError(_ e: NSError){
        self.lastError = e
    }
    
    func navigateTo(_ childViewModel: DocListViewModelable) {
        self.lastVM = childViewModel
    }
    
    /// Default Clipboard Text
   
    func view(_ doc: Content) {
        self.lastDoc = doc
    }
    
}
