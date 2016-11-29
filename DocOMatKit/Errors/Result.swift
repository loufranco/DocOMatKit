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

    case success(T)
    case error(Error)

    public func flatMap<B>(_ f: (T) -> Result<B>) -> Result<B> {
        switch self {
        case .success(let t):
            return f(t)
        case .error(let e):
            return .error(e)
        }
    }

    public func flatMap<B>(_ f: (T) throws -> Result<B>) -> Result<B> {
        switch self {
        case .success(let t):
            do {
                return try f(t)
            } catch let e {
                return .error(e)
            }
        case .error(let e):
            return .error(e)
        }
    }

    public func map<B>(_ f: (T) -> B) -> Result<B> {
        switch self {
        case .success(let t):
            return .success(f(t))
        case .error(let e):
            return .error(e)
        }
    }

    public func mapOptional<B>(_ f: (T) -> B?) -> Result<B> {
        switch self {
        case .success(let t):
            return Result<B>(f(t))
        case .error(let e):
            return .error(e)
        }
    }

    public func map<B>(_ f: (T) throws -> B) -> Result<B> {
        switch self {
        case .success(let t):
            do {
                return try .success(f(t))
            } catch let e {
                return .error(e)
            }
        case .error(let e):
            return .error(e)
        }
    }

    @discardableResult
    public func onError(_ f: (Error) -> ()) -> Result<T> {
        if case let .error(e) = self {
            f(e)
        }
        return self
    }

    public init(_ t: T?, error: Error) {
        if let t = t {
            self = .success(t)
        } else {
            self = .error(error)
        }
    }

    public init(_ t: T?) {
        if let t = t {
            self = .success(t)
        } else {
            self = .error(NSError(domain: "", code: 0, userInfo: nil))
        }
    }

    public func normalizeError(_ error: Error) -> Result<T> {
        if case .error(_) = self {
            return .error(error)
        }
        return self
    }

}

precedencegroup ResultOperatorsGroup {
    higherThan: DefaultPrecedence
    associativity: left
}

infix operator |> : ResultOperatorsGroup

@discardableResult
public func |><A, B> (left: Result<A>, right: (A) -> Result<B>) -> Result<B> {
    return left.flatMap(right)
}

@discardableResult
public func |><A, B> (left: Result<A>, right: (A) throws -> Result<B>) -> Result<B> {
    return left.flatMap(right)
}

@discardableResult
public func |><A, B> (left: A?, right: (A) -> Result<B>) -> Result<B> {
    return Result<A>(left).flatMap(right)
}

@discardableResult
public func |><A, B> (left: Result<A>, right: (A) -> B) -> Result<B> {
    return left.map(right)
}

@discardableResult
public func |><A, B> (left: Result<A>, right: (A) throws -> B) -> Result<B> {
    return left.map(right)
}

@discardableResult
public func |><A, B> (left: Result<A>, right: (A) -> B?) -> Result<B> {
    return left.mapOptional(right)
}

@discardableResult
public func |><A, B> (left: A?, right: (A) -> B?) -> Result<B> {
    return Result<A>(left).mapOptional(right)
}

@discardableResult
public func |><A> (left: Result<A>, right: Result<A>.Fn) -> () {
    return right(left)
}

infix operator !!> : ResultOperatorsGroup

@discardableResult
public func !!><A> (left: Result<A>, right: (Error) -> ()) -> Result<A> {
    return left.onError(right)
}

public extension Optional {
    public var result: Result<Wrapped> {
        return Result<Wrapped>(self)
    }
}
