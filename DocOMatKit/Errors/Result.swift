//
//  Result.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public enum Result<T> {
    public typealias Fn = (Result<T>) -> ()
    
    case Success(T)
    case Error(ErrorType)
    
    public func flatMap<B>(f: (T) -> Result<B>) -> Result<B> {
        switch (self) {
        case Success(let t):
            return f(t)
        case Error(let e):
            return .Error(e)
        }
    }
    
    public func flatMap<B>(f: (T) throws -> Result<B>) -> Result<B> {
        switch (self) {
        case Success(let t):
            do {
                return try f(t)
            } catch let e {
                return .Error(e)
            }
        case Error(let e):
            return .Error(e)
        }
    }
    
    public func map<B>(f: (T) -> B) -> Result<B> {
        switch (self) {
        case Success(let t):
            return .Success(f(t))
        case Error(let e):
            return .Error(e)
        }
    }
    
    public func mapOptional<B>(f: (T) -> B?) -> Result<B> {
        switch (self) {
        case Success(let t):
            return Result<B>(f(t))
        case Error(let e):
            return .Error(e)
        }
    }
    
    public func map<B>(f: (T) throws -> B) -> Result<B> {
        switch (self) {
        case Success(let t):
            do {
                return try .Success(f(t))
            } catch let e {
                return .Error(e)
            }
        case Error(let e):
            return .Error(e)
        }
    }

    public func onError(f: (ErrorType) -> ()) -> Result<T> {
        if case let .Error(e) = self {
            f(e)
        }
        return self
    }
    
    public init(_ t: T?, error: ErrorType) {
        if let t = t {
            self = .Success(t)
        } else {
            self = .Error(error)
        }
    }
    
    public init(_ t: T?) {
        if let t = t {
            self = .Success(t)
        } else {
            self = .Error(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    public func normalizeError(error: ErrorType) -> Result<T> {
        if case .Error(_) = self {
            return .Error(error)
        }
        return self
    }
}

infix operator |> { associativity left precedence 140 }
public func |><A, B> (left: Result<A>, right: (A) -> Result<B>) -> Result<B> {
    return left.flatMap(right)
}

public func |><A, B> (left: Result<A>, right: (A) throws -> Result<B>) -> Result<B> {
    return left.flatMap(right)
}

public func |><A, B> (left: A?, right: (A) -> Result<B>) -> Result<B> {
    return Result<A>(left).flatMap(right)
}

public func |><A, B> (left: Result<A>, right: (A) -> B) -> Result<B> {
    return left.map(right)
}

public func |><A, B> (left: Result<A>, right: (A) throws -> B) -> Result<B> {
    return left.map(right)
}

public func |><A, B> (left: Result<A>, right: (A) -> B?) -> Result<B> {
    return left.mapOptional(right)
}

public func |><A, B> (left: A?, right: (A) -> B?) -> Result<B> {
    return Result<A>(left).mapOptional(right)
}


public func |><A> (left: Result<A>, right: Result<A>.Fn) -> () {
    return right(left)
}

infix operator !!> { associativity left precedence 140 }
public func !!><A> (left: Result<A>, right: (ErrorType) -> ()) -> Result<A> {
    return left.onError(right)
}

public extension Optional {
    public var result: Result<Wrapped> {
        return Result<Wrapped>(self)
    }
}
