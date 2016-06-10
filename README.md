# SectionScrubber

![alt text](https://media.giphy.com/media/xT8qBsHiBYhAp0EomI/giphy.gif)

* The scrubber will move along when scrolling the collectionView it has been added to.
* When you pan the dateScrubber you 'scrub' over the collectionview
* While scrubbing you can set the titles to be shown in the sectionLabel

[![Version](https://img.shields.io/cocoapods/v/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/SectionScrubber)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/SectionScrubber)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/SectionScrubber.svg?style=flat)](https://cocoapods.org/pods/DATAStack)

## Usage

From your UICollectionViewController:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Set custom style for the scrubber
    self.dateScrubber.scrubberImage = UIImage(named: "date-scrubber")
    self.dateScrubber.sectionLabelImage = UIImage(named: "section-label-bckground")
    self.dateScrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
    self.dateScrubber.sectionLabelTextColor = UIColor.blackColor()

    self.dateScrubber.delegate = self
    self.view.addSubview(dateScrubber.view)
}

override func viewDidLayoutSubviews() {
    guard let collectionView = self.collectionView else { return }
    self.dateScrubber.containingViewFrame = collectionView.bounds
    self.dateScrubber.containingViewContentSize = collectionView.contentSize
}

  extension CollectionViewController : DateScrubberDelegate {
    override func scrollViewDidScroll(scrollView: UIScrollView){
        self.dateScrubber.updateFrame(scrollView: scrollView)
        self.dateScrubber.updateSectionTitle(sectionTitleFor(indexPathString)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
        self.dateScrubber.updateSectionTitle(sectionTitleFor(indexPathString)
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
