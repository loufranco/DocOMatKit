//
//  Http.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public typealias MakeErrFn = ([String: AnyObject]?) -> ErrorType

public protocol Http {
    func get(url: NSURL, reportResult: Result<NSData>.Fn) -> ()
    func getJson(url: NSURL, reportResult: Result<AnyObject>.Fn)
    func getJsonAs<T>(url: NSURL, reportResult: Result<T>.Fn)

    var makeErrFn: MakeErrFn { get set }
}


extension Http {
    public func getJson(url: NSURL, reportResult: Result<AnyObject>.Fn) {
        get(url) { r in
            r |> { try NSJSONSerialization.JSONObjectWithData($0, options: NSJSONReadingOptions(rawValue: 0)) }
                |> reportResult
        }
    }
    
    public func getJsonAs<T>(url: NSURL, reportResult: Result<T>.Fn) {
        getJson(url) { r in
            r |> { ($0 as? T).result.normalizeError(self.makeErrFn($0 as? [String : AnyObject])) }
                |> reportResult
        }
    }
}

public struct HttpSynchronous: Http {
    public let extraQueryItems: [NSURLQueryItem]?
    public var makeErrFn: MakeErrFn
    
    public init(extraQueryItems: [NSURLQueryItem]?) {
        self.extraQueryItems = extraQueryItems
        self.makeErrFn = { _ in
            return DocOMatRetrievalCode.Parse.error("Unexpected JSON returned")
        }
    }
    
    public init() {
        self.init(extraQueryItems: nil)
    }
    
    public func get(url: NSURL, reportResult: Result<NSData>.Fn) -> () {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        components?.queryItems = (components?.queryItems ?? []) + (self.extraQueryItems ?? [])
        
        guard let url = components?.URL else {
            return Result<NSData>.Error(DocOMatRetrievalCode.Load.error("Could not parse URL \(components)")) |> reportResult
        }
        do {
            let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions(rawValue: 0))
            Result<NSData>(data) |> reportResult
        } catch let e {
            return Result<NSData>.Error(e) |> reportResult
        }

    }
}
    
