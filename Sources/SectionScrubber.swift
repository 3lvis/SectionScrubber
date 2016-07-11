import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
}

public protocol SectionScrubberDataSource: class {
    func sectionScrubberContainerFrame(sectionScrubber: SectionScrubber) -> CGRect

    func sectionScrubber(sectionScrubber: SectionScrubber, titleForSectionAtIndexPath indexPath: NSIndexPath) -> String
}

public class SectionScrubber: UIView {
    enum VisibilityState {
        case Hidden
        case Visible
    }

    static let RightEdgeInset: CGFloat = 5.0

    /*
     When calculating the NSIndexPath for the current scrubber position we need to use a x and a y coordinate,
     the y coordinate is provided by how far you have scrubbed the scrubber, meanwhile we use a hardcoded x since
     using 5 would ensure us that most of the time the first item in each row will be selected to retreive the
     index path at certain location.
    */
    static let initialXCoordinateToCalculateIndexPath = CGFloat(5)

    public var delegate: SectionScrubberDelegate?

    public var dataSource: SectionScrubberDataSource?

    public var containingViewFrame = CGRectZero

    public var viewHeight = CGFloat(54.0)

    private var scrubberWidth = CGFloat(26.0)

    private let sectionLabel = SectionLabel()

    private let dragGestureRecognizer = UIPanGestureRecognizer()

    private let longPressGestureRecognizer = UILongPressGestureRecognizer()

    private var originalYOffset: CGFloat?

    private weak var collectionView: UICollectionView?

    public var sectionLabelImage: UIImage? {
        didSet {
            if let sectionLabelImage = self.sectionLabelImage {
                self.sectionLabel.labelImage = sectionLabelImage
                self.viewHeight = sectionLabelImage.size.height
            }
        }
    }

    lazy var scrubberImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)

        return imageView
    }()

    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = self.scrubberImage {
                self.scrubberWidth = scrubberImage.size.width
                self.scrubberImageView.image = scrubberImage
            }
        }
    }

    public var sectionLabelFont: UIFont? {
        didSet {
            if let sectionLabelFont = self.sectionLabelFont {
                sectionLabel.setFont(sectionLabelFont)
            }
        }
    }

    public var sectionlabelTextColor: UIColor? {
        didSet {
            if let sectionlabelTextColor = self.sectionlabelTextColor {
                sectionLabel.setTextColor(sectionlabelTextColor)
            }
        }
    }

    private var sectionLabelState = VisibilityState.Hidden {
        didSet {
            if self.sectionLabelState != oldValue {
                if self.sectionLabelState == .Visible { self.setSectionLabelActive() }
                if self.sectionLabelState == .Hidden { self.setSectionLabelInactive() }
                self.updateSectionLabelFrame()
            }
        }
    }

    private var scrubberState = VisibilityState.Hidden {
        didSet {
            if self.scrubberState != oldValue {
                self.updateSectionScrubberFrame()
            }
        }
    }

    public init(collectionView: UICollectionView?) {
        self.collectionView = collectionView

        super.init(frame: CGRectZero)

        self.addSubview(self.scrubberImageView)

        self.setSectionlabelFrame()
        self.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.dragGestureRecognizer.delegate = self
        self.scrubberImageView.addGestureRecognizer(self.dragGestureRecognizer)

        self.longPressGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self
        self.scrubberImageView.addGestureRecognizer(self.longPressGestureRecognizer)

        self.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if self.originalYOffset == nil {
            self.originalYOffset = self.collectionView?.bounds.origin.y ?? 0
        }
        self.containingViewFrame = self.dataSource?.sectionScrubberContainerFrame(self) ?? CGRectZero
        self.updateScrubberFrame()
        self.updateScrubberPosition()
    }

    public func updateSectionTitle(title: String) {
        self.sectionLabel.setText(title)
        self.setSectionlabelFrame()
    }

    private func userInteractionOnScrollViewDetected() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.hideScrubber), object: nil)
        self.performSelector(#selector(self.hideScrubber), withObject: nil, afterDelay: 2)

        if self.scrubberState == .Hidden {
            self.scrubberState = .Visible
        }
    }

    public func updateScrubberPosition() {
        guard let collectionView = self.collectionView else { return }
        guard collectionView.contentSize.height != 0 else { return }
        guard let originalYOffset = self.originalYOffset else { return }

        self.userInteractionOnScrollViewDetected()

        let initialY = self.containingViewFrame.height
        let totalHeight = collectionView.contentSize.height - self.containingViewFrame.height
        let currentY = (collectionView.contentOffset.y - originalYOffset) + self.containingViewFrame.height
        let currentPercentage = (currentY - initialY) / totalHeight
        let containerHeight = (self.containingViewFrame.height - self.viewHeight)
        let y = (containerHeight * currentPercentage) + collectionView.contentOffset.y - originalYOffset
        self.frame = CGRect(x: 0, y: y, width: collectionView.frame.width, height: self.viewHeight)

        let centerPoint = CGPoint(x: SectionScrubber.initialXCoordinateToCalculateIndexPath, y: self.center.y);
        if let indexPath = collectionView.indexPathForItemAtPoint(centerPoint) {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                self.updateSectionTitle(title)
            }
        }
    }

    var startOffset = CGFloat(0)
    func handleScrub(gestureRecognizer: UIGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        guard self.containingViewFrame.height != 0 else { return }
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return }

        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible

        if gesture.state == .Began || gesture.state == .Changed {
            let translation = gesture.translationInView(self)

            if gesture.state == .Began {
                self.startOffset = collectionView.contentOffset.y
            }

            let containerHeight = self.containingViewFrame.height - self.viewHeight
            let totalHeight = collectionView.contentSize.height - self.containingViewFrame.height
            var percentageInView = (translation.y / containerHeight) + (self.startOffset / totalHeight)

            let minimumPercentage = self.originalYOffset! / totalHeight
            if percentageInView < minimumPercentage {
                percentageInView = minimumPercentage

                let centerPoint = CGPoint(x: SectionScrubber.initialXCoordinateToCalculateIndexPath, y: totalHeight * minimumPercentage);
                if let indexPath = collectionView.indexPathForItemAtPoint(centerPoint) {
                    if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                        self.updateSectionTitle(title)
                    }
                }
            }

            let maximumPercentage = 1 + minimumPercentage
            if percentageInView > maximumPercentage {
                percentageInView = maximumPercentage

                let centerPoint = CGPoint(x: SectionScrubber.initialXCoordinateToCalculateIndexPath, y: totalHeight * maximumPercentage);
                if let indexPath = collectionView.indexPathForItemAtPoint(centerPoint) {
                    if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                        self.updateSectionTitle(title)
                    }
                }
            }

            let yOffset = (totalHeight * percentageInView)
            collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
        }
    }

    private func setSectionlabelFrame() {
        let rightOffset = self.sectionLabelState == .Visible ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        self.sectionLabel.frame = CGRectMake(self.frame.width - rightOffset - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func updateScrubberFrame() {
        switch self.scrubberState {
        case .Visible:
            self.scrubberImageView.frame = CGRectMake(self.containingViewFrame.width - self.scrubberWidth - SectionScrubber.RightEdgeInset, 0, self.scrubberWidth, self.viewHeight)
        case .Hidden:
            self.scrubberImageView.frame = CGRectMake(self.containingViewFrame.width, 0, self.scrubberWidth, self.viewHeight)
        }
    }

    private func setSectionLabelActive() {
        self.delegate?.sectionScrubberDidStartScrubbing(self)
        self.sectionLabel.show()
    }

    private func setSectionLabelInactive() {
        self.delegate?.sectionScrubberDidStopScrubbing(self)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideSectionLabel), object: nil)
        self.performSelector(#selector(hideSectionLabel), withObject: nil, afterDelay: 2)
    }

    private func updateSectionLabelFrame() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.setSectionlabelFrame()
            }, completion: nil)
    }

    private func updateSectionScrubberFrame() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.updateScrubberFrame()
            }, completion: nil)
    }

    func hideScrubber() {
        self.scrubberState = .Hidden
    }

    func hideSectionLabel() {
        guard self.sectionLabelState != .Visible else {
            return
        }
        self.sectionLabel.hide()
    }
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
