//
//  DocListViewController.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation

@objc
public protocol DocListViewModelDelegate {
    func reloadData()
    func reloadRow(row: Int)
    func reportError(e: NSError)
}

public protocol DocListViewModelable {
    var title: String { get }
    func docCount() -> Int
    func docTitle(index: Int) -> String
    func docContent(index: Int) -> String
    func connect(delegate: DocListViewModelDelegate)
}

class DocListViewController: UITableViewController, DocListViewModelDelegate {
    
    let viewModel: DocListViewModelable
    var unreportedError: NSError? = nil
    
    init(viewModel: DocListViewModelable) {
        self.viewModel = viewModel
        super.init(style: .Plain)
        self.title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.connect(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let e = self.unreportedError {
            self.unreportedError = nil
            reportError(e)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.docCount()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let id = "DocCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(id) ??
                    UITableViewCell(style: .Default, reuseIdentifier: id)
        cell.textLabel?.text = viewModel.docTitle(indexPath.row)
        return cell
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func reloadRow(row: Int) {
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func reportError(e: NSError) {
        if let _ = self.view.superview {
            let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.unreportedError = e
        }
    }
}