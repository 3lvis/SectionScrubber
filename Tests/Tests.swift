import UIKit
import XCTest

@testable import iOS

class Tests: XCTestCase {

    func testCalculateYPosInView() {

        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInView(forYPosInContentView: 100)

        XCTAssert(result == 50.0)
    }

    func testCalculateYPosInContentView() {
        let dateScrubber = DateScrubber()

        dateScrubber.containingViewFrame = CGRectMake(0, 0, 0, 100)
        dateScrubber.containingViewContentSize = CGSizeMake(0, 200)

        let result = dateScrubber.calculateYPosInContentView(forYPosInView: 50)

        XCTAssert(result == 100.0)
    }
}
