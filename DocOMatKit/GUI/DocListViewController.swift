//
//  DocListViewController.swift
//  DocOMatKit
//
//  Created by Lou Franco on 12/28/15.
//  Copyright © 2015 Lou Franco. All rights reserved.
//

import Foundation


public protocol DocListViewModelDelegate {
    func reloadData()
    func reloadRow(_ row: Int)
    func reportError(_ e: NSError)
    func navigateTo(_ childViewModel: DocListViewModelable)
}

public protocol DocListViewModelable {
    var title: String { get }
    
    func docCount() -> Int
    func docTitle(_ index: Int) -> String
    func docCanHaveChildren(_ index: Int) -> Bool
    func docSelected(_ index: Int)
    
    @discardableResult func connect(delegate: DocListViewModelDelegate) -> DocListViewModelable
    @discardableResult func connect(coordinator: DocViewCoordinator) -> DocListViewModelable
}

class DocListViewController: UITableViewController, DocListViewModelDelegate {
    
    let viewModel: DocListViewModelable
    let viewCoordinator: DocViewCoordinator
    var unreportedError: NSError? = nil
    
    init(viewModel: DocListViewModelable, viewCoordinator: DocViewCoordinator) {
        self.viewModel = viewModel
        self.viewCoordinator = viewCoordinator
        super.init(style: .plain)
        self.title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.connect(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let e = self.unreportedError {
            self.unreportedError = nil
            reportError(e)
        }
    }
    
    /// UITableViewDelegate/DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.docCount()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "DocCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
                    UITableViewCell(style: .default, reuseIdentifier: id)
        cell.textLabel?.text = viewModel.docTitle((indexPath as NSIndexPath).row)
        cell.accessoryType = viewModel.docCanHaveChildren((indexPath as NSIndexPath).row) ? .disclosureIndicator : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.docSelected((indexPath as NSIndexPath).row)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// DocListViewModelDelegate
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func reloadRow(_ row: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    func navigateTo(_ childViewModel: DocListViewModelable) {
        self.navigationController?.pushViewController(DocListViewController(viewModel: childViewModel, viewCoordinator: self.viewCoordinator), animated: true)
    }
    
    func reportError(_ e: NSError) {
        if let _ = self.view.superview {
            let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.unreportedError = e
        }
    }
    
}
