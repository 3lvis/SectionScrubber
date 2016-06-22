# SectionScrubber

![alt text](https://media.giphy.com/media/xT8qBsHiBYhAp0EomI/giphy.gif)

* The scrubber will move along when scrolling the collectionView it has been added to.
* When you pan the sectionScrubber you 'scrub' over the collectionview
* While scrubbing you can set the titles to be shown in the sectionLabel

[![Version](https://img.shields.io/cocoapods/v/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/SectionScrubber)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/SectionScrubber)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/DATAStack)

## Usage

From your UICollectionViewController:

```swift
var sectionScrubber = SectionScrubber()

override func viewDidLoad() {
    super.viewDidLoad()
    // Set custom style for the scrubber
    self.sectionScrubber.scrubberImage = UIImage(named: "date-scrubber")
    self.sectionScrubber.sectionLabelImage = UIImage(named: "section-label-bckground")
    self.sectionScrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
    self.sectionScrubber.sectionLabelTextColor = UIColor.blackColor()
    self.view.addSubview(sectionScrubber.view)
}

override func viewDidLayoutSubviews() {
    guard let collectionView = self.collectionView else { return }
    self.sectionScrubber.containingViewFrame = self.view.bounds //adjust this frame for navigation bars etc.
    self.sectionScrubber.containingViewContentSize = collectionView.contentSize
}

override func scrollViewDidScroll(scrollView: UIScrollView) {
    self.sectionScrubber.updateFrame(scrollView: scrollView)
    self.sectionScrubber.updateSectionTitle(sectionTitleFor(indexPathString)
}

override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.sectionScrubber.updateSectionTitle(sectionTitleFor(indexPathString)
}
```

Implement the SectionScrubberDelegate (all functions have a default implementation and thus are optional):

```swift
extension RemoteCollectionController: SectionScrubberDelegate {
    func sectionScrubber(sectionScrubber: SectionScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat) {
        // function is called when collectionView should update it's contentOffset to respond to dragging of the 
        // sectionScrubber, this is taken care of in the default implementation. 
        // So you don't need to implement this function
    }

    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber) {
        // here you can make your UI respond to when the user starts scrubbing, default implementation is empty
    }

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber) {
        // here you can make your UI respond to when the user stops with scrubbing, default implementation is empty
    }
}
```

## Installation

**SectionScrubber** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SectionScrubber'
```

**SectionScrubber** is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "bakkenbaeck/SectionScrubber"
```

## License

**SectionScrubber** is available under the MIT license. See the LICENSE file for more info.

## Author

Bakken & Bæck, [@bakkenbaeck](https://twitter.com/bakkenbaeck)
