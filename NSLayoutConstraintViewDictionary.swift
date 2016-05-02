//
//  NSLayoutConstraintViewDictionary.swift
//  CollectionSectionScroller
//
//  Created by Igor Ranieri on 02.05.16.
//
//

import UIKit

func NSLayoutConstraintViewsDictionaryFromViews(views: Array<UIView>) -> Dictionary<String, UIView> {
    var viewsDictionary: Dictionary<String, UIView> = Dictionary()
    for view in views {
        viewsDictionary.updateValue(view, forKey:String(view))
    }
    
    return viewsDictionary
}
