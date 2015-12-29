//
//  DocOMatAppDelegate.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public class DocOMatAppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let config = PListConfig(name: "doc-o-mat", bundle: NSBundle.mainBundle())
        guard let vm = DocListViewModel(config: config.backends()?.dict("doc-o-mat")) else {
            return false
        }
        let vc = DocListViewController(viewModel: vm)
        let nc = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = nc
        self.window?.makeKeyAndVisible()

        return true
    }
}