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

    public var dateScrubberSize = CGSizeMake(20,44)

    public var containingViewFrame = UIScreen.mainScreen().bounds
    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    let dragGestureRecognizer = UIPanGestureRecognizer()
    var viewIsBeingDragged = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.view.layer.borderWidth = 0.5
        self.view.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.layer.cornerRadius = dateScrubberSize.width/2
        self.view.clipsToBounds = true

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.view.addGestureRecognizer(self.dragGestureRecognizer)
    }


    public func updateFrame(scrollView scrollView: UIScrollView) {

        if viewIsBeingDragged {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y + containingViewFrame.minY)

        view.frame = CGRectMake(containingViewFrame.width - dateScrubberSize.width, yPos, dateScrubberSize.width, dateScrubberSize.height)
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height * percentageInContentView ) + containingViewFrame.minY
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height


        return containingViewContentSize.height * percentageInView
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        viewIsBeingDragged = gestureRecognizer.state != .Ended

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            let newYPosForDateScrubber =  gestureRecognizer.view!.frame.origin.y + translation.y

            print(newYPosForDateScrubber)
            if newYPosForDateScrubber < containingViewFrame.minY || newYPosForDateScrubber > containingViewFrame.height + containingViewFrame.minY - dateScrubberSize.height {
                return
            }

            view.frame = CGRectMake(containingViewFrame.width - dateScrubberSize.width, newYPosForDateScrubber, dateScrubberSize.width, dateScrubberSize.height)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            delegate?.requestToSetContentView(self, toYPostion: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPointMake(translation.x, 0), inView: self.view)
        }
    }
}