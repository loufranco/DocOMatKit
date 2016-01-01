//
//  CollectionType+Extensions.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/31/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation


public extension CollectionType {
    func dropWhile(isTrue: (Self.Generator.Element) -> Bool) -> Self.SubSequence {
        for i in startIndex..<endIndex {
            if !isTrue(self[i]) {
                return self[i..<endIndex]
            }
        }
        return self[endIndex..<endIndex]
    }
    
    func takeUntil(isTrue: (Self.Generator.Element) -> Bool) -> Self.SubSequence {
        for i in startIndex..<endIndex {
            if isTrue(self[i]) {
                return self[startIndex..<i]
            }
        }
        return self[startIndex..<endIndex]
    }
}
