//
//  SequenceType+Extensions.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/31/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

internal class _TakeSequence<Base : GeneratorType> : SequenceType, GeneratorType {
    internal let pred: (Base.Element) -> Bool
    internal var generator: Base
    
    internal init(_ generator: Base, pred: (Base.Element) -> Bool) {
        self.generator = generator
        self.pred = pred
    }
    
    internal func generate() -> _TakeSequence<Base> {
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

internal class _DropSequence<Base : GeneratorType> : SequenceType, GeneratorType {
    internal let pred: (Base.Element) -> Bool
    internal var generator: Base
    internal var dropping = true
    
    internal init(_ generator: Base, pred: (Base.Element) -> Bool) {
        self.generator = generator
        self.pred = pred
    }
    
    internal func generate() -> _DropSequence<Base> {
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


extension SequenceType {
    public func takeWhile(pred: (Generator.Element) -> Bool) -> AnySequence<Generator.Element> {
        return AnySequence(_TakeSequence(generate(), pred: pred))
    }
    
    public func dropWhile(pred: (Generator.Element) -> Bool) -> AnySequence<Generator.Element> {
        return AnySequence(_DropSequence(generate(), pred: pred))
    }
}
