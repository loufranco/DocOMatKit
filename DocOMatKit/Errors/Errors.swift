//
//  Errors.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/27/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public enum DocOMatErrorDomain: String {
    case Auth = "com.loufranco.DocOMat.AuthErrorDomain"
    case Retrieval = "com.loufranco.DocOMat.RetrievalErrorDomain"
}

public protocol DocOMatErrorCode {
    func domain() -> String
}

public extension DocOMatErrorCode where Self: RawRepresentable {
    public func error() -> Error {
        return error(nil)
    }

    public func error(_ msg: String?) -> Error {
        let userInfo: [String: AnyObject]? = {
            if let msg = msg {
                return [ NSLocalizedDescriptionKey: msg as AnyObject ]
            } else {
                return nil
            }
        }()
        return NSError(domain: self.domain(), code: self.rawValue as! Int, userInfo: userInfo)
    }
}

public enum DocOMatAuthCode: Int, DocOMatErrorCode {
    public func domain() -> String { return DocOMatErrorDomain.Auth.rawValue }

    case failed = -1
}

public enum DocOMatRetrievalCode: Int, DocOMatErrorCode {
    public func domain() -> String { return DocOMatErrorDomain.Retrieval.rawValue }

    case parse = -1
    case load = -2
}
