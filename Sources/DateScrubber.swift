//
//  DateScrubber.swift
//  Pods
//
//  Created by Marijn Schilling on 01/06/16.
//
//

import UIKit

public protocol DateScrubberDelegate {
     func requestToSetContentView(dateScrubber:DateScrubber, toYPostion yPosition: CGFloat)
}

public extension DateScrubberDelegate where Self: UICollectionViewController {
    func requestToSetContentView(dateScrubber:DateScrubber, toYPostion yPosition: CGFloat){

        print("old contentOffset \(self.collectionView?.contentOffset.y)")
        print("new contentOffset \(yPosition)")

        self.collectionView?.setContentOffset(CGPointMake(0,yPosition), animated: true)
    }
}

public class DateScrubber: UIViewController {

    public var delegate : DateScrubberDelegate?

    public var dateScrubberSize = CGSizeMake(44,44)

    public var containingViewFrame = UIScreen.mainScreen().bounds
    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    let dragGestureRecognizer = UIPanGestureRecognizer()
    var viewIsBeingDragged = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellowColor()

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.view.addGestureRecognizer(self.dragGestureRecognizer)
    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        if viewIsBeingDragged {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y)

        view.frame = CGRectMake(containingViewFrame.width - dateScrubberSize.width, containingViewFrame.origin.y + yPos, dateScrubberSize.width, dateScrubberSize.height)
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height) * percentageInContentView
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = yPosInView / (containingViewFrame.height)
        return (containingViewContentSize.height) * percentageInView
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        viewIsBeingDragged = gestureRecognizer.state != .Ended

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            let newYPosForDateScrubber =  gestureRecognizer.view!.frame.origin.y + translation.y

            view.frame = CGRectMake(containingViewFrame.width - dateScrubberSize.width, newYPosForDateScrubber, dateScrubberSize.width, dateScrubberSize.height)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            delegate?.requestToSetContentView(self, toYPostion: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPointMake(0, 0), inView: self.view)
        }
    }
}