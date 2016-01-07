//
//  DocOMatAppDelegate.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public protocol DocViewCoordinator {
    func showDoc()
}

public class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, DocViewCoordinator {
    
    let viewModel: DocListViewModelable!
    let contentViewModel: ContentViewModelable
    
    var masterVC: UIViewController!
    var detailVC: UIViewController!
    var contentVC: ContentViewController!
    
    public init(viewModel: DocListViewModelable, contentViewModel: ContentViewModelable, contentViewDelegate: DocListViewContentDelegate) {
        self.viewModel = viewModel
        self.contentViewModel = contentViewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.connect(contentDelegate: contentViewDelegate)
        prepareViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.viewModel = nil
        fatalError("init(coder:) has not been implemented")
    }
    
    public func prepareViews() {
        let docListVC = DocListViewController(viewModel: self.viewModel, viewCoordinator: self)
        self.contentVC = ContentViewController(viewModel: contentViewModel)
        self.contentVC.navigationItem.leftItemsSupplementBackButton = true
        self.contentVC.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
        
        self.masterVC = UINavigationController(rootViewController: docListVC)
        self.detailVC = UINavigationController(rootViewController: self.contentVC)
        self.viewControllers = [masterVC, detailVC]
        self.delegate = self
    }
    
    /// DocViewCoordinator
    public func showDoc() {
        self.showDetailViewController(self.detailVC, sender: self)
    }
    
    /// UISplitViewControllerDelegate
    
    public func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
            
        return !self.contentVC.hasContent()
    }
    
    public func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        return self.masterVC
    }
    
    public func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        return self.masterVC
    }
    
    public func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        return self.detailVC
    }

    
}

public class DocOMatAppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let config = PListConfig(name: "doc-o-mat", bundle: NSBundle.mainBundle()).backends()?.dict("doc-o-mat")
        let authConfig = PListConfig(name: "Auth/auth", bundle: NSBundle.mainBundle()).dict(config?.string("type"))

        guard let vm = DocListViewModel(config: config, authConfig: authConfig)
            else {
            return false
        }
        
        let contentViewModel = ContentViewModel()
        self.window?.rootViewController = SplitViewController(viewModel: vm, contentViewModel: contentViewModel, contentViewDelegate: contentViewModel)
        self.window?.makeKeyAndVisible()

        return true
    }
}