//
//  Http.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public struct Http<T> {
    public typealias GetFn = (url: NSURL, reportResult: Result<NSData>.Fn) -> ()
    public let get: GetFn
    public init(get: GetFn) {
        self.get = get
    }
}
    
public func httpGetDataSynchronous(url: NSURL, reportResult: Result<NSData>.Fn) -> () {
    guard let data = NSData(contentsOfURL: url) else {
        return Result<NSData>.Error(DocOMatRetrievalCode.Load.error("Could not get contents of \(url)")) |> reportResult
    }
    Result<NSData>(data) |> reportResult
}