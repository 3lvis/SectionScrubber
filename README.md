# SectionScrubber

[![Version](https://img.shields.io/cocoapods/v/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/SectionScrubber)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/SectionScrubber)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/DATAStack)

* The scrubber will move along when scrolling the collectionView it has been added to
* When you pan the sectionScrubber you 'scrub' over the `UICollectionView`
* While scrubbing you can set the titles to be shown in the sectionLabel

## Usage

From your UICollectionViewController:

```swift
lazy var sectionScrubber: SectionScrubber = {
    let scrubber = SectionScrubber(collectionView: self.collectionView!)
    scrubber.scrubberImage = UIImage(named: "date-scrubber")
    scrubber.sectionLabelImage = UIImage(named: "section-label")
    scrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
    scrubber.sectionlabelTextColor = UIColor(red: 69/255, green: 67/255, blue: 76/255, alpha: 0.8)

    return scrubber
}()

override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(sectionScrubber.view)
}

override func scrollViewDidScroll(scrollView: UIScrollView) {
    self.sectionScrubber.updateFrame { indexPath in
        if let indexPath = indexPath {
            let title = titleForIndexPath(indexPath)
            self.sectionScrubber.updateSectionTitle(title)
        }
    }
}

override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.sectionScrubber.updateFrame { indexPath in
        if let indexPath = indexPath {
            let title = titleForIndexPath(indexPath)
            self.sectionScrubber.updateSectionTitle(title)
        }
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
