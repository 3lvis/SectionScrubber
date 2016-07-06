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

    public var delegate: SectionScrubberDelegate?

    public var dataSource: SectionScrubberDataSource?

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var viewHeight = CGFloat(56.0)

    private var scrubberWidth = CGFloat(22.0)

    private var currentSectionTitle = ""

    private let sectionLabel = SectionLabel()

    private let scrubberGestureWidth = CGFloat(44.0)

    private let bottomBorderOffset = CGFloat(3.4)

    private let dragGestureRecognizer = UIPanGestureRecognizer()

    private let longPressGestureRecognizer = UILongPressGestureRecognizer()

    private let scrubberGestureView = UIView()

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

        self.addSubview(scrubberImageView)

        self.setSectionlabelFrame()
        self.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.dragGestureRecognizer.delegate = self

        self.longPressGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self

        self.scrubberGestureView.addGestureRecognizer(self.longPressGestureRecognizer)
        self.scrubberGestureView.addGestureRecognizer(self.dragGestureRecognizer)
        self.addSubview(scrubberGestureView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        self.containingViewFrame = self.dataSource?.sectionScrubberContainerFrame(self) ?? CGRectZero
        self.updateScrubberPosition()

        self.setScrubberFrame()
        self.updateScrubberPosition()
        self.scrubberGestureView.frame = CGRectMake(self.containingViewFrame.width - self.scrubberGestureWidth, 0, self.scrubberGestureWidth, self.viewHeight)
    }

    public func updateScrubberPosition() {
        self.userInteractionOnScrollViewDetected()

        let yPos = self.calculateYPosInView(forYPosInContentView: self.collectionView.contentOffset.y + self.containingViewFrame.minY)
        if yPos > 0 {
            self.setFrame(atYpos: yPos)
        }

        let centerPoint = CGPoint(x: self.center.x + self.collectionView.contentOffset.x, y: self.center.y + self.collectionView.contentOffset.y);
        if let indexPath = self.collectionView.indexPathForItemAtPoint(centerPoint) {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                self.updateSectionTitle(title)
            }
        }
    }

    private func updateSectionTitle(title: String) {
        if self.currentSectionTitle != title {
            self.currentSectionTitle = title

            self.sectionLabel.setText(title)
            self.setSectionlabelFrame()
        }
    }

    private func userInteractionOnScrollViewDetected() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.hideScrubber), object: nil)
        self.performSelector(#selector(self.hideScrubber), withObject: nil, afterDelay: 2)

        if self.scrubberState == .Hidden {
            self.scrubberState = .Visible
        }
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat {
        let percentageInContentView = yPosInContentView / self.collectionView.contentSize.height
        let y =  (self.containingViewFrame.height * percentageInContentView) + self.containingViewFrame.minY

        return y
    }

    func handleScrub(gestureRecognizer: UIGestureRecognizer) {
        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible
        self.userInteractionOnScrollViewDetected()

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {

            let translation = panGestureRecognizer.translationInView(self)
            var newYPosForSectionScrubber = self.frame.origin.y + translation.y

            let scrubberReachedTheTopOfTheScreen = newYPosForSectionScrubber <= containingViewFrame.minY
            if scrubberReachedTheTopOfTheScreen {
                newYPosForSectionScrubber = containingViewFrame.minY

                let centerPoint = CGPoint(x: self.center.x + self.collectionView.contentOffset.x, y: self.viewHeight / 2 + self.containingViewFrame.minY);
                if let indexPath = self.collectionView.indexPathForItemAtPoint(centerPoint) {
                    if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                        self.updateSectionTitle(title)
                    }
                }
            }

            let scrubberReachedEndOfTheScreen = newYPosForSectionScrubber >= self.containingViewFrame.size.height + self.containingViewFrame.minY - bottomBorderOffset
            if scrubberReachedEndOfTheScreen {
                newYPosForSectionScrubber = self.containingViewFrame.size.height + self.containingViewFrame.minY - bottomBorderOffset

                let extraMargin = UIScreen.mainScreen().bounds.height - self.containingViewFrame.height
                let centerPoint = CGPoint(x: self.center.x + self.collectionView.contentOffset.x, y: self.collectionView.contentSize.height - (self.viewHeight / 2) - bottomBorderOffset - extraMargin);
                if let indexPath = self.collectionView.indexPathForItemAtPoint(centerPoint) {
                    if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                        self.updateSectionTitle(title)
                    }
                }
            }

            self.setFrame(atYpos: newYPosForSectionScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForSectionScrubber)

            self.collectionView.setContentOffset(CGPoint(x: 0, y: yPosInContentInContentView), animated: false)

            panGestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self)
        }
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {
        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (self.collectionView.contentSize.height * percentageInView)
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
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.setSectionlabelFrame()
            }, completion: nil)
    }

    private func updateSectionScrubberFrame() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.setScrubberFrame()
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
