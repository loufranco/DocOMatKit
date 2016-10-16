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
    public func authenticate(_ reportResult: Result<BackendDocRetrieval>.Fn) {
        reportResult(.error(DocOMatAuthCode.failed.error("Private GitHub not implemented")))
    }
}

public struct GitHubDocFormatter: BackendDocFormatter {
    public func formatAsHtml(_ doc: File) -> String {
        return doc.content
    }
}

public struct GitHubDocRetrieval: BackendDocRetrieval {
    public let rootUrl: URL
    public let basePath: String?
    public let http: Http
    
    public init(rootUrl: URL, basePath: String?, http: Http) {
        self.rootUrl = rootUrl
        self.basePath = basePath
        self.http = http
        self.http.makeErrFn = makeGitHubError
    }
    
    public func makeGitHubError(_ response: [String: AnyObject]?) -> Error {
        switch (response?["message"] as? String) {
        case .some(let msg):
            return DocOMatRetrievalCode.parse.error(msg)
        default:
            return DocOMatRetrievalCode.parse.error("Unexpected JSON returned: \(response)")
        }
    }
    
    fileprivate func jsonToContentReference(_ json: AnyObject) throws -> Referenceable {
        guard let dict = json as? [String: AnyObject],
            let path = dict["path"] as? String,
            let type = dict["type"] as? String else {
                throw DocOMatRetrievalCode.parse.error("Unexpected JSON returned: \(json)")
        }
        switch (type) {
        case "file":
            return ContentReference(docRetrieval: self, referenceName: path)
        case "dir":
            return FolderReference(docRetrieval: self, referenceName: path)
        default:
            throw DocOMatRetrievalCode.parse.error("Unexpected JSON returned: [\(dict)]")
        }
    }
    
    func getList(_ url: URL, reportResult: @escaping Result<[Referenceable]>.Fn) {
        http.getJsonAs(url) { (r: Result<[AnyObject]>) in
            r |> { try $0.map(self.jsonToContentReference) }
              |> reportResult
        }
    }
    
    public func getList(_ reportResult: @escaping Result<[Referenceable]>.Fn) {
        getList(self.rootUrl.appendingPathComponent(self.basePath ?? ""), reportResult: reportResult)
    }
    
    public func getList(_ ref: Referenceable?, reportResult: @escaping Result<[Referenceable]>.Fn) {
        guard let ref = ref else {
            return getList(reportResult)
        }
        getList(self.rootUrl.appendingPathComponent(ref.referenceName), reportResult: reportResult)
    }
    
    fileprivate func parseDir(_ ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        guard
            let name = response["name"] as? String,
            let path = response["path"] as? String
            else {
                return .error(DocOMatRetrievalCode.parse.error("name or path not found in response: \(response)"))
        }
        return .success(ContentFolder(title: name, content: path, reference: ref))
    }

    fileprivate func parseFile(_ ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        // GitHub returns B64 data in a content key. Unfortunately, GitHub puts \n in the b64 data, so it has to be removed.
        let doc = response["content"] as? String
            |> { $0.replacingOccurrences(of: "\n", with: "") }
            |> { Data(base64Encoded: $0, options: NSData.Base64DecodingOptions(rawValue: 0)) }
            |> { String(data: $0, encoding: String.Encoding.utf8) }
            |> { (content: String) -> Content in
                if ref.referenceName.hasSuffix(".md") {
                    return MarkdownDocument(content: content, reference: ref)
                } else {
                    return UnknownFile(title: ref.title(), content: content, reference: ref)
                }
            }
        
        return doc.normalizeError(DocOMatRetrievalCode.parse.error("Unexpected JSON returned"))
    }
    
    fileprivate func parseContentResponse(_ ref: Referenceable, response: [String: AnyObject]) -> Result<Content> {
        switch (response["type"] as? String) {
        case .none:
            return .error(makeGitHubError(response))
        case .some("dir"):
            return parseDir(ref, response: response)
        case .some("file"):
            return parseFile(ref, response: response)
        case .some(let type):
            return .error(DocOMatRetrievalCode.parse.error("Unexpected type [\(type)] returned"))
        }
    }
    
    public func get(_ ref: Referenceable, reportResult: @escaping Result<Content>.Fn) {
        http.getJsonAs(self.rootUrl.appendingPathComponent(ref.referenceName)) { (r: Result<[String: AnyObject]>) in
            r |> { self.parseContentResponse(ref, response: $0) } |> reportResult
        }
    }
    
    public func getAsFolder(_ ref: Referenceable, reportResult: @escaping Result<Content>.Fn) {
        reportResult(.success(ContentFolder(title: ref.title(), content: ref.referenceName, reference: ref)))
    }
}

public struct GitHubPersonalAccessAuth: BackendAuth {
    public let rootUrl: URL
    public let basePath: String?
    public let token: String
    
    public func authenticate(_ reportResult: Result<BackendDocRetrieval>.Fn) {
        let tokenQuery = URLQueryItem(name: "access_token", value: token)
        reportResult(.success(GitHubDocRetrieval(rootUrl: self.rootUrl, basePath: basePath, http: HttpSynchronous(extraQueryItems: [tokenQuery]))))
    }
}

public struct GitHubFactory: BackendFactory {
    
    let rootUrl: URL
    let basePath: String?
    let authConfig: Config?
    
    public init?(config: Config?, authConfig: Config?) {
        guard let urlString = config?.string("url"), let url = URL(string: urlString) else {
            return nil
        }
        self.rootUrl = url
        self.basePath = config?.string("base-path")
        self.authConfig = authConfig
    }
    
    public func makeAuth() -> BackendAuth {
        switch (self.authConfig?.string("type")) {
            case .some("personal-access-token"):
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
