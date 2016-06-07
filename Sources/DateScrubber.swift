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

    // TODO : Make these height constants more logical
    public let dateScrubberHeight : CGFloat = 48.0

    public let viewHeight : CGFloat = 56.0

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    public var sectionLabelImage: UIImage? {
        didSet {
            self.sectionLabel.labelImage = sectionLabelImage
        }
    }

    let scrubberImageView = UIImageView()

    let sectionLabel = SectionLabel()


    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = self.scrubberImage {

                scrubberImageView.image = scrubberImage
                scrubberImageView.frame = CGRectMake(containingViewFrame.width - scrubberImage.size.width - rightEdgeInset, 0, scrubberImage.size.width, scrubberImage.size.height)
                self.view.addSubview(scrubberImageView)
            }
        }
    }

    public var font : UIFont? {
        didSet {
            if let font = self.font {
                sectionLabel.setFont(font)
            }
        }
    }

    let dragGestureRecognizer = UIPanGestureRecognizer()

    var viewIsBeingDragged = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.sectionLabel.setText("Superlong test String")
        self.sectionLabel.frame = CGRectMake(self.view.frame.width - SectionLabel.RightOffsetForSectionLabel - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
        self.view.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.scrubberImageView.userInteractionEnabled  = true
        self.scrubberImageView.addGestureRecognizer(self.dragGestureRecognizer)
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
            var newYPosForDateScrubber =  self.view.frame.origin.y + translation.y


            if newYPosForDateScrubber < containingViewFrame.minY {
                newYPosForDateScrubber = containingViewFrame.minY
            }

            if newYPosForDateScrubber > containingViewFrame.height + containingViewFrame.minY - dateScrubberHeight {
                newYPosForDateScrubber = containingViewFrame.height + containingViewFrame.minY - dateScrubberHeight
            }

            self.setFrame(atYpos: newYPosForDateScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            self.delegate?.requestToSetContentView(self, toYPosition: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPointMake(translation.x, 0), inView: self.view)
        }
    }

    func setFrame(atYpos yPos: CGFloat){
        self.view.frame = CGRectMake(0, yPos, UIScreen.mainScreen().bounds.width, viewHeight)
    }
}