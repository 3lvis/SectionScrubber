# SectionScrubber

[![Version](https://img.shields.io/cocoapods/v/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/SectionScrubber)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/SectionScrubber)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/DATAStack)

* The scrubber will move along when scrolling the `UICollectionView` it has been added to.
* When you pan the scrubber you 'scrub' over the `UICollectionView`.
* While scrubbing you can choose with title will be shown in the scrubber.

<p align="center">
  <img src="https://raw.githubusercontent.com/bakkenbaeck/SectionScrubber/master/GitHub/demo.gif"/>
</p>

## Usage

From your UICollectionViewController:

```swift
lazy var sectionScrubber: SectionScrubber = {
    let scrubber = SectionScrubber(collectionView: self.collectionView)
    scrubber.scrubberImage = UIImage(named: "date-scrubber")
    scrubber.sectionLabelImage = UIImage(named: "section-label")
    scrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
    scrubber.sectionlabelTextColor = UIColor(red: 69/255, green: 67/255, blue: 76/255, alpha: 0.8)
    scrubber.dataSource = self

    return scrubber
}()

override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView?.addSubview(sectionScrubber)
}

override func scrollViewDidScroll(scrollView: UIScrollView) {
    self.sectionScrubber.updateScrubberPosition()
}

override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.sectionScrubber.updateScrubberPosition()
}

extension RemoteCollectionController: SectionScrubberDataSource {
    func sectionScrubber(sectionScrubber: SectionScrubber, titleForSectionAtIndexPath indexPath: NSIndexPath) -> String {
        return Photo.title(index: indexPath.section)
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
