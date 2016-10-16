//
//  SequenceType+Extensions.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/31/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

internal class _TakeSequence<Base : IteratorProtocol> : Sequence, IteratorProtocol {
    internal let pred: (Base.Element) -> Bool
    internal var generator: Base
    
    internal init(_ generator: Base, pred: @escaping (Base.Element) -> Bool) {
        self.generator = generator
        self.pred = pred
    }
    
    internal func makeIterator() -> _TakeSequence<Base> {
        return self
    }
    
    internal func next() -> Base.Element? {
        if let next = generator.next() {
            if (self.pred(next)) {
                return next
            } else {
                return nil
            }
        }
        
        return nil
    }
}

internal class _DropSequence<Base : IteratorProtocol> : Sequence, IteratorProtocol {
    internal let pred: (Base.Element) -> Bool
    internal var generator: Base
    internal var dropping = true
    
    internal init(_ generator: Base, pred: @escaping (Base.Element) -> Bool) {
        self.generator = generator
        self.pred = pred
    }
    
    internal func makeIterator() -> _DropSequence<Base> {
        return self
    }
    
    internal func next() -> Base.Element? {
        while dropping {
            guard let next = generator.next() else { return nil }
            if (!self.pred(next)) {
                dropping = false
                return next
            }
        }
        return generator.next()
    }
}


extension Sequence {
    public func takeWhile(_ pred: @escaping (Iterator.Element) -> Bool) -> AnySequence<Iterator.Element> {
        return AnySequence(_TakeSequence(makeIterator(), pred: pred))
    }
    
    public func dropWhile(_ pred: @escaping (Iterator.Element) -> Bool) -> AnySequence<Iterator.Element> {
        return AnySequence(_DropSequence(makeIterator(), pred: pred))
    }
}
