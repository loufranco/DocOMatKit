//
//  ContentViewController.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/3/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import UIKit


public protocol ContentViewModelable {
    func connect(delegate: ContentViewModelDelegate)
}

public protocol ContentViewModelDelegate {
    func setText(text: String)
}

public class ContentViewController: UIViewController, ContentViewModelDelegate {

    let textView = UITextView()
    var viewModel: ContentViewModelable!
    
    convenience init(viewModel: ContentViewModelable) {
        self.init()
        self.viewModel = viewModel
        self.viewModel.connect(self)
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = nil
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        self.view = UIView()
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.textView)
        let views = ["tv": self.textView]
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|[tv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views) +
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[tv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        )
    }
    
    public func hasContent() -> Bool {
        return self.textView.text != ""
    }
    
    /// ContentViewModelDelegate
    
    public func setText(text: String) {
        self.textView.text = text
    }
}
