//
//  DocOMatAppDelegate.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public class GitHubViewModel: DocListViewModel {
    
    let factory = GitHubFactory(rootUrl: NSURL(string: "https://api.github.com/repos/loufranco/DocOMatKit/contents/docs")!)
    weak var delegate: DocListViewModelDelegate?
    var docs: [Content]?
    let title: String = "Doc-o-Mat Kit"
    
    init() {
        factory.makeAuth().authenticate { docRetrievalResult in
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
            let r = list[i]
            docRetrieval.get(r) { [weak self] docResult in
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

public class DocOMatAppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let vc = DocListViewController(viewModel: GitHubViewModel())
        let nc = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = nc
        self.window?.makeKeyAndVisible()

        return true
    }
}