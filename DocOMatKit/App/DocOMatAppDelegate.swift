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
    
    public init(viewModel: DocListViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
        prepareViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.viewModel = nil
        fatalError("init(coder:) has not been implemented")
    }
    
    public func prepareViews() {
        let docListVC = DocListViewController(viewModel: self.viewModel)
        let docVC = UIViewController()
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

        guard let vm = DocListViewModel(config: config, authConfig: authConfig) else {
            return false
        }
        
        self.window?.rootViewController = SplitViewController(viewModel: vm)
        self.window?.makeKeyAndVisible()

        return true
    }
}