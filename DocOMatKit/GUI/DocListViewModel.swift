//
//  DocListViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/29/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation


open class DocListViewModel: DocListViewModelable {

    let factory: BackendFactory
    var docs: [Content]?
    let baseReference: Referenceable?
    var coordinator: DocViewCoordinator?

    open let title: String

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

    fileprivate func loadDocs(_ docRetrieval: BackendDocRetrieval, _ list: [Referenceable]) -> Result<()> {
        self.docs = Array<Content>.init(repeating: EmptyContent(), count: list.count)
        self.delegate?.reloadData()
        for i in 0..<list.count {
            list[i].get { [weak self] docResult in
                (docResult
                    |> { (doc: Content) -> Result<()> in
                    guard let strongSelf = self else { return .success(()) }
                    strongSelf.docs?[i] = doc
                    strongSelf.delegate?.reloadRow(i)
                    return .success(())
                })
                .onError { (e: Error) in
                    guard let strongSelf = self else { return }
                    strongSelf.docs?[i] = ErrorContent(error: e, reference: list[i])
                    strongSelf.delegate?.reloadRow(i)
                }
            }
        }
        return .success(())
    }

    fileprivate func loadDocs(_ docRetrieval: BackendDocRetrieval) -> (_ list: [Referenceable]) -> Result<()> {
        return { (_ list: [Referenceable]) in self.loadDocs(docRetrieval, list) }
    }

    open func docCount() -> Int {
        return self.docs?.count ?? 0
    }

    open func docTitle(_ index: Int) -> String {
        return self.docs?[index].title ?? ""
    }

    open func docCanHaveChildren(_ index: Int) -> Bool {
        return self.docs?[index].canHaveChildren() ?? false
    }

    open func docSelected(_ index: Int) {
        if docCanHaveChildren(index) {
            self.delegate?.navigateTo(self.childModel(index))
        } else {
            if let doc = self.docs?[index] {
                self.coordinator!.view(doc)
            }
        }
    }

    fileprivate func childModel(_ index: Int) -> DocListViewModelable {
        let ref = self.docs?[index].reference
        return DocListViewModel(title: ref?.title() ?? self.title, factory: self.factory, baseReference: ref).connect(coordinator: self.coordinator!)
    }

    open func connect(delegate: DocListViewModelDelegate) -> DocListViewModelable {
        self.delegate = delegate

        self.factory.makeAuth().authenticate { [weak self] docRetrievalResult in
            guard let strongSelf = self else { return }
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                docRetrieval.getList(strongSelf.baseReference) { [weak self] (listResult) -> () in
                    guard let strongSelf = self else { return }
                    listResult |> strongSelf.loadDocs(docRetrieval)
                    listResult.onError { e in strongSelf.delegate?.reportError(e as NSError) }
                }
                return .success(())
            }
            docRetrievalResult.onError { e in strongSelf.delegate?.reportError(e as NSError) }
        }

        return self
    }

    /// DocListContentViewDelegate

    open func connect(coordinator: DocViewCoordinator) -> DocListViewModelable {
        self.coordinator = coordinator
        return self
    }

}
