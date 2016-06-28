import UIKit

class RemoteCollectionController: UICollectionViewController {
    var sections = Photo.constructRemoteElements()

    lazy var overlayView: UIView = {
        let view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.0

        return view
    }()

    lazy var sectionScrubber: SectionScrubber = {
        let scrubber = SectionScrubber(collectionView: self.collectionView!)
        scrubber.delegate = self
        scrubber.scrubberImage = UIImage(named: "date-scrubber")
        scrubber.sectionLabelImage = UIImage(named: "section-label")
        scrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
        scrubber.sectionlabelTextColor = UIColor(red: 69/255, green: 67/255, blue: 76/255, alpha: 0.8)

        return scrubber
    }()

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

        let keyWindow = UIApplication.sharedApplication().keyWindow!
        keyWindow.addSubview(self.overlayView)
        keyWindow.addSubview(self.sectionScrubber)
    }

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

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.sectionScrubber.updateFrame { indexPath in
            if let indexPath = indexPath {
                self.sectionScrubber.updateSectionTitle(Photo.title(index: indexPath.section))
            }
        }
    }

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.sectionScrubber.updateFrame { indexPath in
            if let indexPath = indexPath {
                self.sectionScrubber.updateSectionTitle(Photo.title(index: indexPath.section))
            }
        }
    }
}

extension RemoteCollectionController: SectionScrubberDelegate {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber) {
        UIView.animateWithDuration(0.2) {
            self.overlayView.alpha = 0.4
        }
    }

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber) {
        UIView.animateWithDuration(0.2) {
            self.overlayView.alpha = 0
        }
    }
}