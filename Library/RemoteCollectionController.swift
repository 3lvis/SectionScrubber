import UIKit
import SectionScrubber

class RemoteCollectionController: UICollectionViewController {
    var sections = Photo.constructRemoteElements()

    init() {
        super.init(collectionViewLayout: PhotosCollectionLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0

        return view
    }()

    lazy var sectionScrubber: SectionScrubber = {
        let scrubber = SectionScrubber(collectionView: self.collectionView)
        scrubber.delegate = self
        scrubber.dataSource = self
        #if os(iOS)
            scrubber.font = UIFont.boldSystemFont(ofSize: 14)
        #else
            scrubber.font = UIFont.boldSystemFont(ofSize: 30)
        #endif
        scrubber.textColor = UIColor.white
        scrubber.containerColor = UIColor(red: 155.0/255.0, green: 102.0/255.0, blue: 229.0/255.0, alpha: 1)

        return scrubber
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.Identifier)
        self.collectionView?.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeader.Identifier)
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[Photo.title(index: section)]?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.Identifier, for: indexPath) as! PhotoCell
        if let photos = self.sections[Photo.title(index: indexPath.section)] {
            let photo = photos[indexPath.row]
            cell.display(photo)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.Identifier, for: indexPath) as! SectionHeader
        headerView.titleLabel.text = Photo.title(index: indexPath.section)

        return headerView
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var overlayFrame = self.collectionView?.frame ?? CGRect.zero
        overlayFrame.origin.y = scrollView.contentOffset.y
        self.overlayView.frame = overlayFrame

        self.sectionScrubber.updateScrubberPosition()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.sectionScrubber.updateScrubberPosition()
    }
}

extension RemoteCollectionController: SectionScrubberDelegate {
    func sectionScrubberDidStartScrubbing(_ sectionScrubber: SectionScrubber) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .allowUserInteraction, animations: {
            self.overlayView.alpha = 0.4
            }, completion: nil)
    }

    func sectionScrubberDidStopScrubbing(_ sectionScrubber: SectionScrubber) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .allowUserInteraction, animations: {
            self.overlayView.alpha = 0
            }, completion: nil)
    }
}

extension RemoteCollectionController: SectionScrubberDataSource {
    func sectionScrubber(_ sectionScrubber: SectionScrubber, titleForSectionAtIndexPath indexPath: IndexPath) -> String {
        return Photo.title(index: indexPath.section)
    }
}
