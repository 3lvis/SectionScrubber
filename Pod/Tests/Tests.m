@import UIKit;
@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)testPassingExample
{
    NSArray *array;
    XCTAssertNil(array);
}

- (void)testFailingExample
{
    NSArray *array;
    XCTAssertNotNil(array);
}

@end
