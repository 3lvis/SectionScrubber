//
//  DateScrubber.swift
//  Pods
//
//  Created by Marijn Schilling on 01/06/16.
//
//

import UIKit

public class DateScrubber: UIViewController {

    let dragGestureRecognizer = UIPanGestureRecognizer()

    /// the minimum position for the date scrubber from the top, can be overwritten by the client
    public var minimumPosition : CGFloat = 64.0

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellowColor()


        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.view.addGestureRecognizer(self.dragGestureRecognizer)

    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        let scrollPercentage = scrollView.contentOffset.y / scrollView.contentSize.height
        let yPos = (scrollView.bounds.size.height - minimumPosition) * scrollPercentage

        view.frame = CGRectMake(0,yPos + minimumPosition, 44,44)
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.frame.origin = CGPointMake(0, gestureRecognizer.view!.frame.origin.y + translation.y)
            gestureRecognizer.setTranslation(CGPointMake(0,0), inView: self.view)
        }
    }
}