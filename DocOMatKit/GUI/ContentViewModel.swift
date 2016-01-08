//
//  ContentViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/3/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import Foundation

public class ContentViewModel: ContentViewModelable {
    
    var delegate: ContentViewModelDelegate?
    
    public func view(doc: Content) {
        guard let delegate = self.delegate else { return }
        delegate.setText(doc.content)
    }
    
    public func connect(delegate: ContentViewModelDelegate) ->ContentViewModelable {
        self.delegate = delegate
        return self
    }
}