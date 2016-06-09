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
```swift
    // initialise the dateScrubber
    let dateScrubber = DateScrubber()
    
    //set the collectionViewController as the delegate of the dateScrubber
    public var delegate : DateScrubberDelegate?

    //set the frame of the view that will contain the dateScrubber, default is UIScreen.mainScreen().bounds
    var containingViewFrame: CGRect

    //set the contentSize of the view that will contain the dateScrubber, default is UIScreen.mainScreen().bounds.size
    var containingViewContentSize: CGSize

    //call this function from scrollViewDidScroll to update the dateScrubber frame
    func updateFrame(scrollView: UIScrollView) 
    
    //call this function from scrollViewDidScroll  to set the section title
    func updateSectionTitle(title: String) 
```

Set these properties to customize the look of the dateScrubber

```swift
    //set an image that will be used as the scubber
    var scrubberImage: UIImage? 
    
    //set an image for the background of the sectionLabel
    var sectionLabelImage: UIImage? 

    //the font that will be used in the sectionlabel
    var sectionLabelFont: UIFont? 
    
    //the font that will be used in the sectionlabel
    var sectionlabelTextColor: UIColor? 
    
    //turn the vertical scroll bars off, the dateScrubber will fullfill this function now! 
    self.collectionView?.showsVerticalScrollIndicator = false

```

#### DateScrubberDelegate (protocol)

Make your collectionView conform to the protocol to make use of the default behaviour to control the contentOffset of the collectionView with the dateScrubber

```swift
class CollectionViewController: UICollectionViewController, DateScrubberDelegate {
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
