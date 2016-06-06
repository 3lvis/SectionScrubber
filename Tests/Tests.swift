import UIKit
import XCTest

@testable import iOS

class Tests: XCTestCase {

    func testMoveTheScrubberWhenScrollingTheCollectionView() {

        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInView(forYPosInContentView: 100)

        XCTAssert(result == 50.0)
    }

    func testScrollCollectionViewWhenMovingTheScrubber() {
        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInContentView(forYPosInView: 50)

        XCTAssert(result == 100.0)
    }

    func testMoveTheScrubberWhenScrollingTheCollectionViewWithOffset() {

        let dateScrubber = DateScrubber()

        let offset : CGFloat = 10.0

        dateScrubber.containingViewFrame = CGRectMake(0, offset, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInView(forYPosInContentView: 0)

        XCTAssert(result == offset)
    }

    func testScrollCollectionViewWithOffsetWhenMovingTheScrubber() {
        let dateScrubber = DateScrubber()

        let offset : CGFloat  = 10.0

        dateScrubber.containingViewFrame = CGRectMake(0, offset, 0, 10)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 20)

        let result = dateScrubber.calculateYPosInContentView(forYPosInView: offset)

        XCTAssert(result == 0)
    }
}
