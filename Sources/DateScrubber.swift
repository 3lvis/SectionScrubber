//
//  DateScrubber.swift
//  Pods
//
//  Created by Marijn Schilling on 01/06/16.
//
//

import UIKit

public class DateScrubber: UIViewController {

    /// the minimum position for the date scrubber from the top of the view, can be overwritten by the client
    public var minimumPosition : CGFloat = 64.0

    public var dateScrubberSize = CGSizeMake(44,44)

    public var containingViewWidth = UIScreen.mainScreen().bounds.width

    let dragGestureRecognizer = UIPanGestureRecognizer()

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellowColor()

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.view.addGestureRecognizer(self.dragGestureRecognizer)

    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        let scrollPercentage = scrollView.contentOffset.y / scrollView.contentSize.height
        let yPos = (scrollView.bounds.size.height - minimumPosition) * scrollPercentage

        view.frame = CGRectMake(containingViewWidth - dateScrubberSize.width, yPos + minimumPosition, dateScrubberSize.width, dateScrubberSize.height)
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            gestureRecognizer.view!.frame.origin = CGPointMake(containingViewWidth - dateScrubberSize.width, gestureRecognizer.view!.frame.origin.y + translation.y)
            gestureRecognizer.setTranslation(CGPointMake(0,0), inView: self.view)
        }
    }
}