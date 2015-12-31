//
//  DocListViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/29/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public class DocListViewModel: DocListViewModelable {
    
    let config: Config?
    let factory: BackendFactory!
    var docs: [Content]?
    
    public let title: String
    
    weak var delegate: DocListViewModelDelegate?
    
    init?(config: Config?, authConfig: Config?) {
        self.config = config
        self.title = self.config?.string("title") ?? ""
        self.factory = makeBackendFactory(config, authConfig: authConfig)
        guard let _ = self.factory else {
            return nil
        }
    }
    
    private func loadDocs(docRetrieval: BackendDocRetrieval)(list: [Referenceable]) -> Result<()> {
        self.docs = Array<Content>.init(count: list.count, repeatedValue: EmptyContent())
        self.delegate?.reloadData()
        for i in 0..<list.count {
            list[i].get() { [weak self] docResult in
                (docResult
                    |> { (doc: Content) -> Result<()> in
                    guard let strongSelf = self else { return .Success(()) }
                    strongSelf.docs?[i] = doc
                    strongSelf.delegate?.reloadRow(i)
                    return .Success(())
                })
                .onError() { (e: ErrorType) in
                    guard let strongSelf = self else { return }
                    strongSelf.docs?[i] = ErrorContent(error: e, reference: list[i])
                    strongSelf.delegate?.reloadRow(i)
                }
            }
        }
        return .Success(())
    }
    
    public func docCount() -> Int {
        return self.docs?.count ?? 0
    }
    
    public func docTitle(index: Int) -> String {
        return self.docs?[index].title ?? ""
    }
    
    public func docContent(index: Int) -> String {
        return self.docs?[index].content ?? ""
    }
    
    public func docCanHaveChildren(index: Int) -> Bool {
        return self.docs?[index].canHaveChildren() ?? false
    }
    
    public func connect(delegate: DocListViewModelDelegate) {
        self.delegate = delegate
        
        self.factory.makeAuth().authenticate { [weak self] docRetrievalResult in
            guard let strongSelf = self else { return }
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                docRetrieval.getList { [weak self] (listResult) -> () in
                    guard let strongSelf = self else { return }
                    listResult |> strongSelf.loadDocs(docRetrieval)
                    listResult.onError() { e in strongSelf.delegate?.reportError(e as NSError) }
                }
                return .Success(())
            }
            docRetrievalResult.onError() { e in strongSelf.delegate?.reportError(e as NSError) }
        }
    }
}