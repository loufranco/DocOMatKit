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
    let title: String
    let factory: BackendFactory!
    var docs: [Content]?
    
    weak var delegate: DocListViewModelDelegate?
    
    init?(config: Config?) {
        self.config = config
        self.title = self.config?.string("title") ?? ""
        self.factory = makeBackendFactory(config)
        guard let _ = self.factory else {
            return nil
        }
        
        self.factory.makeAuth().authenticate { docRetrievalResult in
            docRetrievalResult |> { (docRetrieval) -> Result<()> in
                docRetrieval.getList { [weak self] (listResult) -> () in
                    guard let strongSelf = self else { return }
                    listResult |> strongSelf.loadDocs(docRetrieval)
                }
                return .Success(())
            }
        }
    }
    
    private func loadDocs(docRetrieval: BackendDocRetrieval)(list: [Referenceable]) -> Result<()> {
        self.docs = Array<Content>.init(count: list.count, repeatedValue: EmptyContent())
        self.delegate?.reloadData()
        for i in 0..<list.count {
            docRetrieval.get(list[i]) { [weak self] docResult in
                docResult |> { (doc) -> Result<()> in
                    guard let strongSelf = self else { return .Success(()) }
                    strongSelf.docs?[i] = doc
                    strongSelf.delegate?.reloadRow(i)
                    return .Success(())
                }
            }
        }
        return .Success(())
    }
    
    func docCount() -> Int {
        return self.docs?.count ?? 0
    }
    
    func docTitle(index: Int) -> String {
        return self.docs?[index].title ?? ""
    }
    
    func connect(delegate: DocListViewModelDelegate) {
        self.delegate = delegate
    }
}