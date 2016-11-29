//
//  ContentViewModel.swift
//  DocOMatKit
//
//  Created by Lou Franco on 1/3/16.
//  Copyright © 2016 Lou Franco. All rights reserved.
//

import Foundation

open class ContentViewModel: ContentViewModelable {

    var delegate: ContentViewModelDelegate?

    open func view(_ doc: Content) {
        guard let delegate = self.delegate else { return }
        delegate.setText(doc.content)
    }

    open func connect(_ delegate: ContentViewModelDelegate) -> ContentViewModelable {
        self.delegate = delegate
        return self
    }

}
