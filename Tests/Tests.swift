import UIKit
import XCTest

@testable import iOS

class Tests: XCTestCase {

    func moveTheScrubberWhenScrollingTheCollectionView() {

        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInView(forYPosInContentView: 100)

        XCTAssert(result == 50.0)
    }

    func scrollCollectionViewWhenMovingTheScrubber() {
        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInContentView(forYPosInView: 50)

        XCTAssert(result == 100.0)
    }

    func moveTheScrubberWhenScrollingTheCollectionViewWithOffset() {

        let dateScrubber = DateScrubber()

        let offset : CGFloat = 10.0

        dateScrubber.containingViewFrame = CGRectMake(0, offset, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInView(forYPosInContentView: 0)

        XCTAssert(result == offset)
    }

    func scrollCollectionViewWithOffsetWhenMovingTheScrubber() {
        let dateScrubber = DateScrubber()

        let offset : CGFloat  = 10.0

        dateScrubber.containingViewFrame = CGRectMake(0, offset, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInContentView(forYPosInView: offset)

        XCTAssert(result == 0)
    }
}
