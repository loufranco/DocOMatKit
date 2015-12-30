//
//  Http.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public protocol Http {
    func get(url: NSURL, reportResult: Result<NSData>.Fn) -> ()
    func getJson(url: NSURL, reportResult: Result<AnyObject>.Fn)
    func getJsonAs<T>(url: NSURL, reportResult: Result<T>.Fn)
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
            r |> { ($0 as? T).result.normalizeError(DocOMatRetrievalCode.Parse.error("Unexpected JSON type returned: [\($0)]")) }
                |> reportResult
        }
    }
}

public struct HttpSynchronous: Http {
    public func get(url: NSURL, reportResult: Result<NSData>.Fn) -> () {
        guard let data = NSData(contentsOfURL: url) else {
            return Result<NSData>.Error(DocOMatRetrievalCode.Load.error("Could not get contents of \(url)")) |> reportResult
        }
        Result<NSData>(data) |> reportResult
    }
}
    
