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
    
    init(viewModel: DocListViewModelable) {
        self.viewModel = viewModel
        super.init(style: .Plain)
        self.title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}