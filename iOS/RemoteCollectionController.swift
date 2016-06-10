import UIKit

class RemoteCollectionController: UICollectionViewController {
    var sections = Photo.constructRemoteElements()
    let sectionScrubber = SectionScrubber()
    var keyWindow: UIWindow?
    let overlayView = UIView(frame: UIScreen.mainScreen().bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.registerClass(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.Identifier)
        self.collectionView?.registerClass(SectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeader.Identifier)
        self.collectionView?.showsVerticalScrollIndicator = false

        var count = 0
        for i in 0 ..< self.sections.count {
            if let photos = self.sections[Photo.title(index: i)] {
                count += photos.count
            }
        }

        self.sectionScrubber.delegate = self
        self.sectionScrubber.scrubberImage = UIImage(named: "date-scrubber")
        self.sectionScrubber.sectionLabelImage = UIImage(named: "section-label")
        self.sectionScrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
        self.sectionScrubber.sectionlabelTextColor = UIColor(red: 69/255, green: 67/255, blue: 76/255, alpha: 0.8)
        self.keyWindow = UIApplication.sharedApplication().keyWindow;
        self.keyWindow?.addSubview(sectionScrubber)
        self.overlayView.backgroundColor = UIColor.blackColor()
        self.overlayView.alpha = 0.4

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let columns = CGFloat(4)
        let bounds = UIScreen.mainScreen().bounds
        let size = (bounds.width - columns) / columns
        layout.itemSize = CGSize(width: size, height: size)
        layout.headerReferenceSize = CGSizeMake(bounds.width, 22);
    }

    override func viewDidLayoutSubviews() {
        self.sectionScrubber.containingViewFrame = CGRectMake(0, 64, self.view.bounds.width, self.view.bounds.height - 64)
        self.sectionScrubber.containingViewContentSize = self.collectionView!.contentSize
        self.sectionScrubber.updateFrame(scrollView: self.collectionView!)
    }

    func alertControllerWithTitle(title: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        return alertController
    }
}

extension RemoteCollectionController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.sections.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[Photo.title(index: section)]?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCell.Identifier, forIndexPath: indexPath) as! PhotoCell
        if let photos = self.sections[Photo.title(index: indexPath.section)] {
            let photo = photos[indexPath.row]
            cell.display(photo)
        }

        return cell
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: SectionHeader.Identifier, forIndexPath: indexPath) as! SectionHeader
        headerView.titleLabel.text = Photo.title(index: indexPath.section)
       
        return headerView
    }
}

extension RemoteCollectionController: SectionScrubberDelegate {
    override func scrollViewDidScroll(scrollView: UIScrollView){
        self.sectionScrubber.updateFrame(scrollView: scrollView)

        let centerPoint = CGPoint(x: self.sectionScrubber.center.x + scrollView.contentOffset.x, y: self.sectionScrubber.center.y + scrollView.contentOffset.y);
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(centerPoint) {
            self.sectionScrubber.updateSectionTitle(Photo.title(index: indexPath.section))
        }
    }

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
        let centerPoint = CGPoint(x: self.sectionScrubber.center.x + scrollView.contentOffset.x, y: self.sectionScrubber.center.y + scrollView.contentOffset.y);
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(centerPoint) {
            self.sectionScrubber.updateSectionTitle(Photo.title(index: indexPath.section))
        }
    }

    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber) {
        self.keyWindow?.addSubview(self.overlayView)
        self.keyWindow?.bringSubviewToFront(self.sectionScrubber)
    }

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber) {
        self.overlayView.removeFromSuperview()
    }
}