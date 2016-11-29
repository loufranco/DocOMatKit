//
//  Http.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public typealias MakeErrFn = ([String: AnyObject]?) -> Error

public protocol Http {
    func get(_ url: URL, reportResult: @escaping Result<Data>.Fn) -> ()
    func getJson(_ url: URL, reportResult: @escaping Result<Any>.Fn)
    func getJsonAs<T>(_ url: URL, reportResult: @escaping Result<T>.Fn)

    var makeErrFn: MakeErrFn { get set }
}


extension Http {

    public func getJson(_ url: URL, reportResult: @escaping (Result<Any>) -> ()) {
        get(url) { r in
            r |> { try JSONSerialization.jsonObject(with: $0, options: JSONSerialization.ReadingOptions(rawValue: 0)) }
              |> reportResult
        }
    }

    public func getJsonAs<T>(_ url: URL, reportResult: @escaping Result<T>.Fn) {
        getJson(url) { r in
            r |> { ($0 as? T).result.normalizeError(self.makeErrFn($0 as? [String: AnyObject])) }
              |> reportResult
        }
    }

}

public struct HttpSynchronous: Http {
    public let extraQueryItems: [URLQueryItem]?
    public var makeErrFn: MakeErrFn

    public init(extraQueryItems: [URLQueryItem]?) {
        self.extraQueryItems = extraQueryItems
        self.makeErrFn = { _ in
            return DocOMatRetrievalCode.parse.error("Unexpected JSON returned")
        }
    }

    public init() {
        self.init(extraQueryItems: nil)
    }

    public func get(_ url: URL, reportResult: @escaping Result<Data>.Fn) -> () {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = (components?.queryItems ?? []) + (self.extraQueryItems ?? [])

        guard let url = components?.url else {
            return Result<Data>.error(DocOMatRetrievalCode.load.error("Could not parse URL \(components)")) |> reportResult
        }
        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions(rawValue: 0))
            Result<Data>(data) |> reportResult
        } catch let e {
            return Result<Data>.error(e) |> reportResult
        }

    }

}
