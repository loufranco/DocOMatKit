//
//  ContentViewController.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/3/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import UIKit


public protocol ContentViewModelable {
    func view(doc: Content)
    func connect(delegate: ContentViewModelDelegate) -> ContentViewModelable
}

public protocol ContentViewModelDelegate {
    func setText(text: String)
}

public class ContentViewController: UIViewController, ContentViewModelDelegate {

    let textView = UITextView()
    let viewModel: ContentViewModelable
    
    init(viewModel: ContentViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.connect(self)
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
