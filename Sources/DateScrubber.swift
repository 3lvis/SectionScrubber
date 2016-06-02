//
//  DateScrubber.swift
//  Pods
//
//  Created by Marijn Schilling on 01/06/16.
//
//

import UIKit

public class DateScrubber: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellowColor()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        let scrollPercentage = scrollView.contentOffset.y / scrollView.contentSize.height
        let yPos = scrollView.bounds.size.height * scrollPercentage

        view.frame = CGRectMake(0,yPos,44,44)
    }
}