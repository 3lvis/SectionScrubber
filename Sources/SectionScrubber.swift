import UIKit

public protocol SectionScrubberDelegate {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
}

public extension SectionScrubberDelegate where Self: UICollectionViewController {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber) {
    }

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber) {
    }
}

public class SectionScrubber: UIView {
    enum VisibilityState {
        case Hidden
        case Visible
    }

    static let RightEdgeInset: CGFloat = 5.0

    public var delegate: SectionScrubberDelegate?

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    public var viewHeight = CGFloat(56.0)

    private var scrubberWidth = CGFloat(22.0)

    private var currentSectionTitle = ""

    private let sectionLabel = SectionLabel()

    private let scrubberGestureWidth = CGFloat(44.0)

    private let bottomBorderOffset = CGFloat(3.4)

    private let dragGestureRecognizer = UIPanGestureRecognizer()
    private let longPressGestureRecognizer = UILongPressGestureRecognizer()

    private unowned var collectionView: UICollectionView

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

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView

        super.init(frame: CGRectZero)

        self.setScrubberFrame()
        self.addSubview(scrubberImageView)

        self.setSectionlabelFrame()
        self.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        self.dragGestureRecognizer.delegate = self

        self.longPressGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self

        let scrubberGestureView = UIView(frame: CGRectMake(self.containingViewFrame.width - self.scrubberGestureWidth, 0, self.scrubberGestureWidth, self.viewHeight))
        scrubberGestureView.addGestureRecognizer(self.longPressGestureRecognizer)
        scrubberGestureView.addGestureRecognizer(self.dragGestureRecognizer)
        self.addSubview(scrubberGestureView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateFrame(completion: ((indexPath: NSIndexPath?) -> Void)) {
        self.userInteractionOnScrollViewDetected()

        let yPos = self.calculateYPosInView(forYPosInContentView: self.collectionView.contentOffset.y + self.containingViewFrame.minY)
        if yPos > 0 {
            self.setFrame(atYpos: yPos)
        }

        let centerPoint = CGPoint(x: self.center.x + self.collectionView.contentOffset.x, y: self.center.y + self.collectionView.contentOffset.y);
        let indexPath = self.collectionView.indexPathForItemAtPoint(centerPoint)
        completion(indexPath: indexPath)
    }

    public func updateSectionTitle(title: String) {
        if self.currentSectionTitle != title {
            self.currentSectionTitle = title

            self.sectionLabel.setText(title)
            self.setSectionlabelFrame()
        }
    }

    private func userInteractionOnScrollViewDetected() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideScrubber), object: nil)
        self.performSelector(#selector(hideScrubber), withObject: nil, afterDelay: 2)

        if self.scrubberState == .Hidden {
            self.scrubberState = .Visible
        }
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat {
        let percentageInContentView = yPosInContentView / self.containingViewContentSize.height
        let y =  (containingViewFrame.height * percentageInContentView) + self.containingViewFrame.minY

        return y
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {
        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleScrub(gestureRecognizer: UIGestureRecognizer) {
        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible
        self.userInteractionOnScrollViewDetected()

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {

            let translation = panGestureRecognizer.translationInView(self)
            var newYPosForSectionScrubber = self.frame.origin.y + translation.y

            if newYPosForSectionScrubber < containingViewFrame.minY {
                newYPosForSectionScrubber = containingViewFrame.minY
            }

            if newYPosForSectionScrubber > self.containingViewFrame.size.height + self.containingViewFrame.minY - bottomBorderOffset {
                newYPosForSectionScrubber = self.containingViewFrame.size.height + self.containingViewFrame.minY - bottomBorderOffset
            }

            self.setFrame(atYpos: newYPosForSectionScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForSectionScrubber)

            self.collectionView.setContentOffset(CGPoint(x: 0, y: yPosInContentInContentView), animated: false)

            panGestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self)
        }
    }

    private func setFrame(atYpos yPos: CGFloat) {
        self.frame = CGRect(x: 0, y: yPos, width: UIScreen.mainScreen().bounds.width, height: self.viewHeight)
    }

    private func setSectionlabelFrame() {
        let rightOffset = self.sectionLabelState == .Visible ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        self.sectionLabel.frame = CGRectMake(self.frame.width - rightOffset - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func setScrubberFrame() {
        switch self.scrubberState {
        case .Visible:
            scrubberImageView.frame = CGRectMake(self.containingViewFrame.width - self.scrubberWidth - SectionScrubber.RightEdgeInset, 0, self.scrubberWidth, self.viewHeight)
        case .Hidden:
            scrubberImageView.frame = CGRectMake(self.containingViewFrame.width, 0, self.scrubberWidth, self.viewHeight)
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
        UIView.animateWithDuration(0.2) {
            self.setSectionlabelFrame()
        }
    }

    private func updateSectionScrubberFrame() {
        UIView.animateWithDuration(0.2) {
            self.setScrubberFrame()
        }
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

    var originalOriginY: CGFloat?
    override public func layoutSubviews() {
        if self.originalOriginY == nil {
            self.originalOriginY = -self.collectionView.bounds.origin.y
        }

        if let originalOriginY = self.originalOriginY {
            self.containingViewFrame = CGRectMake(0, originalOriginY, self.collectionView.bounds.width, self.collectionView.bounds.height - originalOriginY - self.viewHeight)
            self.containingViewContentSize = self.collectionView.contentSize
            self.updateFrame() { _ in }
        }
    }
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}