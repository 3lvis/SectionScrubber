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

        self.collectionView?.setContentOffset(CGPointMake(0,yPosition), animated: true)
    }
}

public class DateScrubber: UIViewController {

    public var delegate : DateScrubberDelegate?

    /// the minimum position for the date scrubber from the top of the view, can be overwritten by the client
    public var minimumPosition : CGFloat = 64.0

    public var dateScrubberSize = CGSizeMake(44,44)

    public var containingViewSize = UIScreen.mainScreen().bounds.size
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

        view.frame = CGRectMake(containingViewSize.width - dateScrubberSize.width, yPos + minimumPosition, dateScrubberSize.width, dateScrubberSize.height)
    }

    private func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewSize.height - minimumPosition) * percentageInContentView
    }

    private func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {
        let percentageInView = yPosInView / (containingViewSize.height - minimumPosition)
        return (containingViewContentSize.height) * percentageInView
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        viewIsBeingDragged = gestureRecognizer.state != .Ended
        print("view is being dragged = \(viewIsBeingDragged)")

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)

            // TODO : find better name!
            let yPos =  gestureRecognizer.view!.frame.origin.y + translation.y
            gestureRecognizer.setTranslation(CGPointMake(0,0), inView: self.view)

            view.frame = CGRectMake(containingViewSize.width - dateScrubberSize.width, yPos, dateScrubberSize.width, dateScrubberSize.height)


            delegate?.requestToSetContentView(self, toYPostion: yPos)
        }
    }
}