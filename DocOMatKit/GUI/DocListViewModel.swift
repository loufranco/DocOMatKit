//
//  DocListViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/29/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public protocol DocListViewContentDelegate {
    func view(doc: Content)
}

public class DocListViewModel: DocListViewModelable {
    
    let factory: BackendFactory!
    var docs: [Content]?
    let baseReference: Referenceable?
    var contentDelegate: DocListViewContentDelegate?
    
    public let title: String
    
    var delegate: DocListViewModelDelegate?
    
    public convenience init?(config: Config?, authConfig: Config?) {
        guard let factory = makeBackendFactory(config, authConfig: authConfig) else {
            return nil
        }
        self.init(title: config?.string("title") ?? "", factory: factory, baseReference: nil)
    }
    
    public init(title: String, factory: BackendFactory, baseReference: Referenceable?) {
        self.title = title
        self.factory = factory
        self.baseReference = baseReference
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
                .onError { (e: ErrorType) in
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
    
    public func docCanHaveChildren(index: Int) -> Bool {
        return self.docs?[index].canHaveChildren() ?? false
    }
    
    public func docSelected(index: Int) {
        if docCanHaveChildren(index) {
            self.delegate?.navigateTo(self.childModel(index))
        } else {
            if let doc = self.docs?[index] {
                self.contentDelegate?.view(doc)
                self.delegate?.showDoc()
            }
        }
    }
    
    private func childModel(index: Int) -> DocListViewModelable {
        let ref = self.docs?[index].reference
        return DocListViewModel(title: ref?.title() ?? self.title, factory: self.factory, baseReference: ref)
    }
    
    public func connect(delegate delegate: DocListViewModelDelegate) {
        self.delegate = delegate
        
        self.factory.makeAuth().authenticate { [weak self] docRetrievalResult in
            guard let strongSelf = self else { return }
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                docRetrieval.getList(strongSelf.baseReference) { [weak self] (listResult) -> () in
                    guard let strongSelf = self else { return }
                    listResult |> strongSelf.loadDocs(docRetrieval)
                    listResult.onError { e in strongSelf.delegate?.reportError(e as NSError) }
                }
                return .Success(())
            }
            docRetrievalResult.onError { e in strongSelf.delegate?.reportError(e as NSError) }
        }
    }
    
    /// DocListContentViewDelegate
    
    public func connect(contentDelegate contentDelegate: DocListViewContentDelegate) {
        self.contentDelegate = contentDelegate
    }
    
}