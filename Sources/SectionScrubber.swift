import UIKit

public protocol SectionScrubberDelegate {
    func sectionScrubber(sectionScrubber: SectionScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat)

    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
}

public extension SectionScrubberDelegate where Self: UICollectionViewController {
    func sectionScrubber(sectionScrubber: SectionScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat) {
        self.collectionView?.setContentOffset(CGPoint(x: 0, y: yPosition), animated: false)
    }

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

    private let scrubberImageView = UIImageView()

    private let sectionLabel = SectionLabel()

    private let scrubberGestureWidth = CGFloat(44.0)

    private let bottomBorderOffset = CGFloat(3.4)

    private let dragGestureRecognizer = UIPanGestureRecognizer()
    private let longPressGestureRecognizer = UILongPressGestureRecognizer()

    public var sectionLabelImage: UIImage? {
        didSet {
            if let sectionLabelImage = self.sectionLabelImage {
                self.sectionLabel.labelImage = sectionLabelImage
                self.viewHeight = sectionLabelImage.size.height
            }
        }
    }

    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = self.scrubberImage {
                self.scrubberWidth = scrubberImage.size.width
                self.scrubberImageView.image = scrubberImage
                self.setScrubberFrame()
                self.addSubview(scrubberImageView)
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

    public init() {
        super.init(frame: CGRectZero)

        self.setSectionlabelFrame()
        self.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        self.dragGestureRecognizer.delegate = self

        self.longPressGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self

        let scrubberGestureView = UIView(frame: CGRectMake(self.containingViewFrame.width - scrubberGestureWidth, 0, scrubberGestureWidth, self.viewHeight))
        scrubberGestureView.addGestureRecognizer(self.longPressGestureRecognizer)
        scrubberGestureView.addGestureRecognizer(self.dragGestureRecognizer)
        self.addSubview(scrubberGestureView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateFrame(scrollView scrollView: UIScrollView) {
        self.userInteractionOnScrollViewDetected()

        if self.sectionLabelState == .Visible {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y + containingViewFrame.minY)

        self.setFrame(atYpos: yPos)
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

            self.delegate?.sectionScrubber(self, didRequestToSetContentViewToYPosition: yPosInContentInContentView)

            panGestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self)
        }
    }

    private func setFrame(atYpos yPos: CGFloat) {
        self.frame = CGRectMake(0, yPos, UIScreen.mainScreen().bounds.width, viewHeight)
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
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}