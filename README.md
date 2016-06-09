# DateScrubber

![alt text](https://media.giphy.com/media/xT8qBsHiBYhAp0EomI/giphy.gif)

* The scrubber will move along when scrolling the collectionView it has been added to.
* When you pan the dateScrubber you 'scrub' over the collectionview
* While scrubbing you can set the titles to be shown in the sectionLabel

[![Version](https://img.shields.io/cocoapods/v/DateScrubber.svg?style=flat)](https://cocoapods.org/pods/DateScrubber)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/DateScrubber)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/DateScrubber.svg?style=flat)](https://cocoapods.org/pods/DATAStack)


## Usage

#### DateScrubber (class)

From your UICollectionViewController:

```swift

override func viewDidLoad() {
    super.viewDidLoad()
    self.dateScrubber.delegate = self

    //set custom style for the scrubber
    self.dateScrubber.scrubberImage = UIImage(named: "date-scrubber")
    self.dateScrubber.sectionLabelImage = UIImage(named: "section-label-bckground")
    self.dateScrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
    self.dateScrubber.sectionLabelTextColor = UIColor.blackColor()

    self.view.addSubview(dateScrubber.view)
}

override func viewDidLayoutSubviews() {
    guard let collectionView = self.collectionView else { return }

    self.dateScrubber.containingViewFrame = collectionView.bounds
    self.dateScrubber.containingViewContentSize = collectionView.contentSize
}

  extension CollectionViewController : DateScrubberDelegate {

    override func scrollViewDidScroll(scrollView: UIScrollView){
        dateScrubber.updateFrame(scrollView: scrollView)

        let centerPoint = CGPoint(x: dateScrubber.view.center.x + scrollView.contentOffset.x, y: dateScrubber.view.center.y + scrollView.contentOffset.y);

        if let indexPath = self.collectionView?.indexPathForItemAtPoint(centerPoint) {
            self.dateScrubber.updateSectionTitle(sectionTitleFor(indexPath.section))
        }
    }
}
```

## Installation

**DateScrubber** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DateScrubber'
```

**DateScrubber** is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "bakkenbaeck/DateScrubber"
```

## License

**DateScrubber** is available under the MIT license. See the LICENSE file for more info.

## Author

Bakken & Bæck, [@bakkenbaeck](https://twitter.com/bakkenbaeck)
