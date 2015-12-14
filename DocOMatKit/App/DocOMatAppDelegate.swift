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
        let vc = HomeTabsViewController()
        self.window?.rootViewController = vc;
        self.window?.makeKeyAndVisible();

        return true
    }
}