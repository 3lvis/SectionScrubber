//
//  DateScrubber.swift
//  Pods
//
//  Created by Marijn Schilling on 01/06/16.
//
//

import UIKit

public protocol DateScrubberDelegate {
     func requestToSetContentView(dateScrubber:DateScrubber, toYPosition yPosition: CGFloat)
}

public extension DateScrubberDelegate where Self: UICollectionViewController {
    func requestToSetContentView(dateScrubber:DateScrubber, toYPosition yPosition: CGFloat){

        self.collectionView?.setContentOffset(CGPointMake(0,yPosition), animated: true)
    }
}

public class DateScrubber: UIViewController {


    public var delegate : DateScrubberDelegate?

    public let rightEdgeInset : CGFloat = 5.0

    public var dateScrubberSize = CGSizeMake(0,0)

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    public var image : UIImage? {
        didSet {
            dateScrubberSize = image?.size ?? dateScrubberSize
            self.view.addSubview(UIImageView(image: image))
        }
    }

    let dragGestureRecognizer = UIPanGestureRecognizer()

    var viewIsBeingDragged = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.view.addGestureRecognizer(self.dragGestureRecognizer)
    }


    public func updateFrame(scrollView scrollView: UIScrollView) {

        if viewIsBeingDragged {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y + containingViewFrame.minY)

        self.setFrame(atYpos: yPos)
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height * percentageInContentView ) + containingViewFrame.minY
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height


        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        self.viewIsBeingDragged = gestureRecognizer.state != .Ended

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            var newYPosForDateScrubber =  gestureRecognizer.view!.frame.origin.y + translation.y


            if newYPosForDateScrubber < containingViewFrame.minY {
                newYPosForDateScrubber = containingViewFrame.minY
            }

            if newYPosForDateScrubber > containingViewFrame.height + containingViewFrame.minY - dateScrubberSize.height {
                newYPosForDateScrubber = containingViewFrame.height + containingViewFrame.minY - dateScrubberSize.height
            }

            self.setFrame(atYpos: newYPosForDateScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            self.delegate?.requestToSetContentView(self, toYPosition: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPointMake(translation.x, 0), inView: self.view)
        }
    }

    func setFrame(atYpos yPos: CGFloat){
        self.view.frame = CGRectMake(containingViewFrame.width - dateScrubberSize.width - rightEdgeInset, yPos, dateScrubberSize.width, dateScrubberSize.height)
    }
}