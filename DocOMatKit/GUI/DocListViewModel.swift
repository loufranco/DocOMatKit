//
//  DocListViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/29/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public class DocListViewModel: DocListViewModelable {
    
    let factory: BackendFactory!
    var docs: [Content]?
    let baseReference: Referenceable?
    
    public let title: String
    
    weak var delegate: DocListViewModelDelegate?
    
    convenience init?(config: Config?, authConfig: Config?) {
        guard let factory = makeBackendFactory(config, authConfig: authConfig) else {
            return nil
        }
        self.init(title: config?.string("title") ?? "", factory: factory, baseReference: nil)
    }
    
    init(title: String, factory: BackendFactory, baseReference: Referenceable?) {
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
    
    public func docContent(index: Int) -> String {
        return self.docs?[index].content ?? ""
    }
    
    public func docCanHaveChildren(index: Int) -> Bool {
        return self.docs?[index].canHaveChildren() ?? false
    }
    
    public func childModel(index: Int) -> DocListViewModelable {
        return DocListViewModel(title: self.title, factory: self.factory, baseReference: self.docs?[index].reference)
    }
    
    public func connect(delegate: DocListViewModelDelegate) {
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
}