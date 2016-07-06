import UIKit

class RemoteCollectionController: UICollectionViewController {
    var sections = Photo.constructRemoteElements()

    lazy var overlayView: UIView = {
        let view = UIView(frame: self.collectionView?.frame ?? CGRectZero)
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0

        return view
    }()

    lazy var sectionScrubber: SectionScrubber = {
        let scrubber = SectionScrubber(collectionView: self.collectionView)
        scrubber.delegate = self
        scrubber.dataSource = self
        scrubber.scrubberImage = UIImage(named: "date-scrubber")
        scrubber.sectionLabelImage = UIImage(named: "section-label")
        scrubber.sectionLabelFont = UIFont(name: "DINNextLTPro-Light", size: 18)
        scrubber.sectionlabelTextColor = UIColor(red: 69/255, green: 67/255, blue: 76/255, alpha: 0.8)

        return scrubber
    }()

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
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

        self.collectionView?.addSubview(self.overlayView)
        self.collectionView?.addSubview(self.sectionScrubber)
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
        var overlayFrame = self.overlayView.frame
        overlayFrame.origin.y = scrollView.contentOffset.y
        self.overlayView.frame = overlayFrame

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
        UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: {
            self.overlayView.alpha = 0.4
            }, completion: nil)
    }

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .AllowUserInteraction, animations: {
            self.overlayView.alpha = 0
            }, completion: nil)
    }
}

extension RemoteCollectionController: SectionScrubberDataSource {
    func sectionScrubberContainerFrame(sectionScrubber: SectionScrubber) -> CGRect {
        let collectionFrame = self.collectionView?.frame ?? CGRectZero
        var frame = CGRect(x: 0, y: 0, width: collectionFrame.size.width, height: collectionFrame.size.height)

        var navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        let navigationBarHidden = self.navigationController?.navigationBar.hidden ?? true
        if navigationBarHidden {
            navigationBarHeight = 0
        }
        frame.origin.y += navigationBarHeight
        frame.size.height -= navigationBarHeight

        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        frame.origin.y += statusBarHeight
        frame.size.height -= statusBarHeight

        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        frame.size.height -= tabBarHeight

        return frame
    }
}
