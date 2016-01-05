//
//  DocOMatAppDelegate.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation


public class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    let viewModel: DocListViewModelable!
    let contentViewModel: ContentViewModelable
    
    public init(viewModel: DocListViewModelable, contentViewModel: ContentViewModelable, contentViewDelegate: DocListViewContentDelegate) {
        self.viewModel = viewModel
        self.contentViewModel = contentViewModel
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
        self.viewModel.connect(contentDelegate: contentViewDelegate)
        prepareViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.viewModel = nil
        fatalError("init(coder:) has not been implemented")
    }
    
    public func prepareViews() {
        let docListVC = DocListViewController(viewModel: self.viewModel)
        let docVC = ContentViewController(viewModel: contentViewModel)
        docVC.navigationItem.leftItemsSupplementBackButton = true
        docVC.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
        self.viewControllers = [
            UINavigationController(rootViewController: docListVC),
            UINavigationController(rootViewController: docVC)]
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