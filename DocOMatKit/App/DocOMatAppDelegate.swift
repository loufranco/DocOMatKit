//
//  DocOMatAppDelegate.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/13/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

public protocol DocViewCoordinator {
    func view(_ doc: Content)
}

open class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, DocViewCoordinator {

    let viewModel: DocListViewModelable
    let contentViewModel: ContentViewModelable

    var masterVC: UIViewController!
    var detailVC: UIViewController!
    var contentVC: ContentViewController!

    public init(viewModel: DocListViewModelable, contentViewModel: ContentViewModelable) {
        self.viewModel = viewModel
        self.contentViewModel = contentViewModel
        super.init(nibName: nil, bundle: nil)

        self.viewModel.connect(coordinator: self)
        prepareViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func prepareViews() {
        let docListVC = DocListViewController(viewModel: self.viewModel, viewCoordinator: self)
        self.contentVC = ContentViewController(viewModel: contentViewModel)
        self.contentVC.navigationItem.leftItemsSupplementBackButton = true
        self.contentVC.navigationItem.leftBarButtonItem = self.displayModeButtonItem

        self.masterVC = UINavigationController(rootViewController: docListVC)
        self.detailVC = UINavigationController(rootViewController: self.contentVC)
        self.viewControllers = [masterVC, detailVC]
        self.delegate = self
    }

    /// DocViewCoordinator

    open func view(_ doc: Content) {
        self.contentViewModel.view(doc)
        self.showDetailViewController(self.detailVC, sender: self)
    }

    /// UISplitViewControllerDelegate

    open func splitViewController(_ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {

        return !self.contentVC.hasContent()
    }

    open func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return self.masterVC
    }

    open func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return self.masterVC
    }

    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return self.detailVC
    }


}

open class DocOMatAppDelegate: UIResponder, UIApplicationDelegate {
    open var window: UIWindow?

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let config = PListConfig(name: "doc-o-mat", bundle: Bundle.main).backends()?.dict("doc-o-mat")
        let authConfig = PListConfig(name: "Auth/auth", bundle: Bundle.main).dict(config?.string("type"))

        guard let vm = DocListViewModel(config: config, authConfig: authConfig)
            else {
            return false
        }

        let contentViewModel = ContentViewModel()
        self.window?.rootViewController = SplitViewController(viewModel: vm, contentViewModel: contentViewModel)
        self.window?.makeKeyAndVisible()

        return true
    }
}
