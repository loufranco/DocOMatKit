//
//  GitHubBackend.swift
//  DocOMatKit
//
//  Created by Louis Franco on 12/16/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

/// Defines the types needed to get documentation from GitHub

public struct GitHubPrivateAuth: BackendAuth {
    public func authenticate(completion: Result<BackendDocRetrieval>.Fn) {
        completion(.Error(DocOMatAuthCode.Failed.error("Private GitHub not implemented")))
    }
}

public struct GitHubDocFormatter: BackendDocFormatter {
    public func formatAsHtml(doc: File) -> String {
        return ""
    }
}

public struct GitHubDocRetrieval: BackendDocRetrieval {
    public let rootUrl: NSURL
    public let http: Http<NSData>
    
    public init(rootUrl: NSURL, http: Http<NSData>) {
        self.rootUrl = rootUrl
        self.http = http
    }
    
    private func getJson(url: NSURL, reportResult: Result<AnyObject>.Fn) {
        self.http.get(url: url) { r in
            r |> { try NSJSONSerialization.JSONObjectWithData($0, options: NSJSONReadingOptions(rawValue: 0)) }
                |> reportResult
        }
    }
    
    private func getJsonAs<T>(url: NSURL, reportResult: Result<T>.Fn) {
        getJson(url) { r in
            r |> { ($0 as? T).result.normalizeError(DocOMatRetrievalCode.Parse.error("Unexpected JSON type returned: [\($0)]")) }
                |> reportResult
        }
    }
    
    private func jsonToContentReference(json: AnyObject) throws -> Referenceable {
        guard let dict = json as? [String: AnyObject],
            let name = dict["name"] as? String else {
                throw DocOMatRetrievalCode.Parse.error()
        }
        return ContentReference(docRetrieval: self, referenceName: name)
    }
    
    func getList(url: NSURL, reportResult: Result<[Referenceable]>.Fn) {
        getJsonAs(url) { (r: Result<[AnyObject]>) in
            r |> { try $0.map(self.jsonToContentReference) }
                |> reportResult
        }
    }
    
    public func getList(reportResult: Result<[Referenceable]>.Fn) {
        getList(self.rootUrl, reportResult: reportResult)
    }
    
    public func getList(ref: Referenceable, reportResult: Result<[Referenceable]>.Fn) {
        getList(self.rootUrl.URLByAppendingPathComponent(ref.referenceName), reportResult: reportResult)
    }
    
    private func parseDir(ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        guard
            let name = response["name"] as? String,
            let path = response["path"] as? String
            else {
                return .Error(DocOMatRetrievalCode.Parse.error("name or path not found in response: \(response)"))
        }
        return .Success(ContentFolder(title: name, content: path, reference: ref))
    }

    private func parseFile(ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        let doc =
        Result<String>((response["content"] as? String)?.stringByReplacingOccurrencesOfString("\n", withString: ""))
            |> { NSData(base64EncodedString: $0, options: NSDataBase64DecodingOptions(rawValue: 0)) }
            |> { String(data: $0, encoding: NSUTF8StringEncoding) }
            |> { (content: String) -> Content in
                if ref.referenceName.hasSuffix(".md") {
                    return MarkdownDocument(content: content, reference: ref)
                } else {
                    return UnknownFile(title: ref.referenceName, content: content, reference: ref)
                }
            }
        
        return doc.normalizeError(DocOMatRetrievalCode.Parse.error("Unexpected JSON returned"))
    }
    
    private func parseContentResponse(ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        switch (response["type"] as? String) {
        case .None:
            return .Error(DocOMatRetrievalCode.Parse.error("Unexpected JSON returned"))
        case .Some("dir"):
            return parseDir(ref, response: response)
        case .Some("file"):
            return parseFile(ref, response: response)
        case .Some(let type):
            return .Error(DocOMatRetrievalCode.Parse.error("Unexpected type [\(type)] returned"))
        }
    }
    
    public func get(ref: Referenceable, reportResult: Result<Content>.Fn) {
        getJsonAs(self.rootUrl.URLByAppendingPathComponent(ref.referenceName)) { (r: Result<[String: AnyObject]>) in
            r |> { self.parseContentResponse(ref, response: $0) } |> reportResult
        }
    }
}

public struct GitHubFactory: BackendFactory {
    
    public let rootUrl: NSURL!
    
    public init(rootUrl: NSURL) {
        self.rootUrl = rootUrl
    }
    
    public init?(config: Config?) {
        guard let urlString = config?.string("url") else {
            self.rootUrl = nil
            return nil
        }
        self.rootUrl = NSURL(string: urlString)
    }
    
    public func makeAuth() -> BackendAuth {
        return NullAuth(docRetrieval: makeDocRetrieval())
    }
    
    public func makeDocFormatter() -> BackendDocFormatter {
        return GitHubDocFormatter()
    }
    
    private func makeDocRetrieval() -> BackendDocRetrieval {
        let get: Http<NSData>.GetFn = httpGetDataSynchronous
        return GitHubDocRetrieval(rootUrl: rootUrl, http: Http<NSData>(get: get))
    }
}
