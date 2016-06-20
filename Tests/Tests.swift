import UIKit
import XCTest

class Tests: XCTestCase {
    func testMoveTheScrubberWhenScrollingTheCollectionView() {
        let sectionScrubber = SectionScrubber()
        sectionScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        sectionScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = sectionScrubber.calculateYPosInView(forYPosInContentView: 100)
        XCTAssert(result == 50.0)
    }

    func testScrollCollectionViewWhenMovingTheScrubber() {
        let sectionScrubber = SectionScrubber()
        sectionScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        sectionScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = sectionScrubber.calculateYPosInContentView(forYPosInView: 50)
        XCTAssert(result == 100.0)
    }

    func testMoveTheScrubberWhenScrollingTheCollectionViewWithOffset() {
        let sectionScrubber = SectionScrubber()
        let offset : CGFloat = 10.0
        sectionScrubber.containingViewFrame = CGRectMake(0, offset, 0, 100)
        sectionScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = sectionScrubber.calculateYPosInView(forYPosInContentView: 0)
        XCTAssert(result == offset)
    }

    func testScrollCollectionViewWithOffsetWhenMovingTheScrubber() {
        let sectionScrubber = SectionScrubber()
        let offset : CGFloat  = 64.0
        sectionScrubber.containingViewFrame = CGRectMake(0, offset, 0, 568)
        sectionScrubber.containingViewContentSize = CGSizeMake(0, 5620)

        let result = sectionScrubber.calculateYPosInContentView(forYPosInView: offset)
        XCTAssert(result == -offset)
    }
}
