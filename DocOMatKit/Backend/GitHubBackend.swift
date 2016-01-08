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
    public func authenticate(reportResult: Result<BackendDocRetrieval>.Fn) {
        reportResult(.Error(DocOMatAuthCode.Failed.error("Private GitHub not implemented")))
    }
}

public struct GitHubDocFormatter: BackendDocFormatter {
    public func formatAsHtml(doc: File) -> String {
        return doc.content
    }
}

public struct GitHubDocRetrieval: BackendDocRetrieval {
    public let rootUrl: NSURL
    public let basePath: String?
    public let http: Http
    
    public init(rootUrl: NSURL, basePath: String?, http: Http) {
        self.rootUrl = rootUrl
        self.basePath = basePath
        self.http = http
        self.http.makeErrFn = makeGitHubError
    }
    
    public func makeGitHubError(response: [String: AnyObject]?) -> ErrorType {
        switch (response?["message"] as? String) {
        case .Some(let msg):
            return DocOMatRetrievalCode.Parse.error(msg)
        default:
            return DocOMatRetrievalCode.Parse.error("Unexpected JSON returned: \(response)")
        }
    }
    
    private func jsonToContentReference(json: AnyObject) throws -> Referenceable {
        guard let dict = json as? [String: AnyObject],
            let path = dict["path"] as? String,
            let type = dict["type"] as? String else {
                throw DocOMatRetrievalCode.Parse.error("Unexpected JSON returned: \(json)")
        }
        switch (type) {
        case "file":
            return ContentReference(docRetrieval: self, referenceName: path)
        case "dir":
            return FolderReference(docRetrieval: self, referenceName: path)
        default:
            throw DocOMatRetrievalCode.Parse.error("Unexpected JSON returned: [\(dict)]")
        }
    }
    
    func getList(url: NSURL, reportResult: Result<[Referenceable]>.Fn) {
        http.getJsonAs(url) { (r: Result<[AnyObject]>) in
            r |> { try $0.map(self.jsonToContentReference) }
                |> reportResult
        }
    }
    
    public func getList(reportResult: Result<[Referenceable]>.Fn) {
        getList(self.rootUrl.URLByAppendingPathComponent(self.basePath ?? ""), reportResult: reportResult)
    }
    
    public func getList(ref: Referenceable?, reportResult: Result<[Referenceable]>.Fn) {
        guard let ref = ref else {
            return getList(reportResult)
        }
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
        // GitHub returns B64 data in a content key. Unfortunately, GitHub puts \n in the b64 data, so it has to be removed.
        let doc = response["content"] as? String
            |> { $0.stringByReplacingOccurrencesOfString("\n", withString: "") }
            |> { NSData(base64EncodedString: $0, options: NSDataBase64DecodingOptions(rawValue: 0)) }
            |> { String(data: $0, encoding: NSUTF8StringEncoding) }
            |> { (content: String) -> Content in
                if ref.referenceName.hasSuffix(".md") {
                    return MarkdownDocument(content: content, reference: ref)
                } else {
                    return UnknownFile(title: ref.title(), content: content, reference: ref)
                }
            }
        
        return doc.normalizeError(DocOMatRetrievalCode.Parse.error("Unexpected JSON returned"))
    }
    
    private func parseContentResponse(ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        switch (response["type"] as? String) {
        case .None:
            return .Error(makeGitHubError(response))
        case .Some("dir"):
            return parseDir(ref, response: response)
        case .Some("file"):
            return parseFile(ref, response: response)
        case .Some(let type):
            return .Error(DocOMatRetrievalCode.Parse.error("Unexpected type [\(type)] returned"))
        }
    }
    
    public func get(ref: Referenceable, reportResult: Result<Content>.Fn) {
        http.getJsonAs(self.rootUrl.URLByAppendingPathComponent(ref.referenceName)) { (r: Result<[String: AnyObject]>) in
            r |> { self.parseContentResponse(ref, response: $0) } |> reportResult
        }
    }
    
    public func getAsFolder(ref: Referenceable, reportResult: Result<Content>.Fn) {
        reportResult(.Success(ContentFolder(title: ref.title(), content: ref.referenceName, reference: ref)))
    }
}

public struct GitHubPersonalAccessAuth: BackendAuth {
    public let rootUrl: NSURL
    public let basePath: String?
    public let token: String
    
    public func authenticate(reportResult: Result<BackendDocRetrieval>.Fn) {
        let tokenQuery = NSURLQueryItem(name: "access_token", value: token)
        reportResult(.Success(GitHubDocRetrieval(rootUrl: self.rootUrl, basePath: basePath, http: HttpSynchronous(extraQueryItems: [tokenQuery]))))
    }
}

public struct GitHubFactory: BackendFactory {
    
    let rootUrl: NSURL
    let basePath: String?
    let authConfig: Config?
    
    public init?(config: Config?, authConfig: Config?) {
        guard let urlString = config?.string("url"), let url = NSURL(string: urlString) else {
            return nil
        }
        self.rootUrl = url
        self.basePath = config?.string("base-path")
        self.authConfig = authConfig
    }
    
    public func makeAuth() -> BackendAuth {
        switch (self.authConfig?.string("type")) {
            case .Some("personal-access-token"):
                if let token = self.authConfig?.string("token") {
                    return GitHubPersonalAccessAuth(rootUrl: self.rootUrl, basePath: self.basePath, token: token)
                }
            default:
                return NullAuth(docRetrieval: GitHubDocRetrieval(rootUrl: rootUrl, basePath: basePath, http: HttpSynchronous()))
        }
        return NullAuth(docRetrieval: GitHubDocRetrieval(rootUrl: rootUrl, basePath: basePath, http: HttpSynchronous()))
    }
    
    public func makeDocFormatter() -> BackendDocFormatter {
        return GitHubDocFormatter()
    }
}
