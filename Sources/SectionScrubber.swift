import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
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
            if let sectionLabelImage = sectionLabelImage {
                sectionLabel.labelImage = sectionLabelImage
                viewHeight = sectionLabelImage.size.height
            }
        }
    }

    lazy var scrubberImageView: UIImageView = {
        let imageView = UIImageView()

        return imageView
    }()

    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = scrubberImage {
                scrubberWidth = scrubberImage.size.width
                scrubberImageView.image = scrubberImage
            }
        }
    }

    public var sectionLabelFont: UIFont? {
        didSet {
            if let sectionLabelFont = sectionLabelFont {
                sectionLabel.setFont(sectionLabelFont)
            }
        }
    }

    public var sectionlabelTextColor: UIColor? {
        didSet {
            if let sectionlabelTextColor = sectionlabelTextColor {
                sectionLabel.setTextColor(sectionlabelTextColor)
            }
        }
    }

    private var sectionLabelState = VisibilityState.Hidden {
        didSet {
            if sectionLabelState != oldValue {
                if sectionLabelState == .Visible { setSectionLabelActive() }
                if sectionLabelState == .Hidden { setSectionLabelInactive() }
                updateSectionLabelFrame()
            }
        }
    }

    private var scrubberState = VisibilityState.Hidden {
        didSet {
            if scrubberState != oldValue {
                updateSectionScrubberFrame()
            }
        }
    }

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView

        super.init(frame: CGRectZero)

        setScrubberFrame()
        addSubview(scrubberImageView)

        setSectionlabelFrame()
        addSubview(sectionLabel)

        dragGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        dragGestureRecognizer.delegate = self

        longPressGestureRecognizer.addTarget(self, action: #selector(handleScrub))
        longPressGestureRecognizer.minimumPressDuration = 0.2
        longPressGestureRecognizer.cancelsTouchesInView = false
        longPressGestureRecognizer.delegate = self

        let scrubberGestureView = UIView(frame: CGRectMake(containingViewFrame.width - scrubberGestureWidth, 0, scrubberGestureWidth, viewHeight))
        scrubberGestureView.addGestureRecognizer(longPressGestureRecognizer)
        scrubberGestureView.addGestureRecognizer(dragGestureRecognizer)
        addSubview(scrubberGestureView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateFrame(completion: ((indexPath: NSIndexPath?) -> Void)) {
        userInteractionOnScrollViewDetected()

        let yPos = calculateYPosInView(forYPosInContentView: collectionView.contentOffset.y + containingViewFrame.minY)
        if yPos > 0 {
            setFrame(atYpos: yPos)
        }

        let centerPoint = CGPoint(x: center.x + collectionView.contentOffset.x, y: center.y + collectionView.contentOffset.y);
        let indexPath = collectionView.indexPathForItemAtPoint(centerPoint)
        completion(indexPath: indexPath)
    }

    public func updateSectionTitle(title: String) {
        if currentSectionTitle != title {
            currentSectionTitle = title

            sectionLabel.setText(title)
            setSectionlabelFrame()
        }
    }

    private func userInteractionOnScrollViewDetected() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideScrubber), object: nil)
        performSelector(#selector(hideScrubber), withObject: nil, afterDelay: 2)

        if scrubberState == .Hidden {
            scrubberState = .Visible
        }
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat {
        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        let y =  (containingViewFrame.height * percentageInContentView) + containingViewFrame.minY

        return y
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {
        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleScrub(gestureRecognizer: UIGestureRecognizer) {
        sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible
        userInteractionOnScrollViewDetected()

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {

            let translation = panGestureRecognizer.translationInView(self)
            var newYPosForSectionScrubber = frame.origin.y + translation.y

            if newYPosForSectionScrubber < containingViewFrame.minY {
                newYPosForSectionScrubber = containingViewFrame.minY
            }

            if newYPosForSectionScrubber > containingViewFrame.size.height + containingViewFrame.minY - bottomBorderOffset {
                newYPosForSectionScrubber = containingViewFrame.size.height + containingViewFrame.minY - bottomBorderOffset
            }

            setFrame(atYpos: newYPosForSectionScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForSectionScrubber)

            collectionView.setContentOffset(CGPoint(x: 0, y: yPosInContentInContentView), animated: false)

            panGestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self)
        }
    }

    private func setFrame(atYpos yPos: CGFloat) {
        frame = CGRect(x: 0, y: yPos, width: UIScreen.mainScreen().bounds.width, height: viewHeight)
    }

    private func setSectionlabelFrame() {
        let rightOffset = sectionLabelState == .Visible ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        sectionLabel.frame = CGRectMake(frame.width - rightOffset - sectionLabel.sectionlabelWidth, 0, sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func setScrubberFrame() {
        switch scrubberState {
        case .Visible:
            scrubberImageView.frame = CGRectMake(containingViewFrame.width - scrubberWidth - SectionScrubber.RightEdgeInset, 0, scrubberWidth, viewHeight)
        case .Hidden:
            scrubberImageView.frame = CGRectMake(containingViewFrame.width, 0, scrubberWidth, viewHeight)
        }
    }

    private func setSectionLabelActive() {
        delegate?.sectionScrubberDidStartScrubbing(self)
        sectionLabel.show()
    }

    private func setSectionLabelInactive() {
        delegate?.sectionScrubberDidStopScrubbing(self)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideSectionLabel), object: nil)
        performSelector(#selector(hideSectionLabel), withObject: nil, afterDelay: 2)
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
        scrubberState = .Hidden
    }

    func hideSectionLabel() {
        guard sectionLabelState != .Visible else {
            return
        }
        sectionLabel.hide()
    }

    var originalOriginY: CGFloat?
    override public func layoutSubviews() {
        if originalOriginY == nil {
            originalOriginY = -collectionView.bounds.origin.y
        }

        if let originalOriginY = originalOriginY {
            containingViewFrame = CGRectMake(0, originalOriginY, collectionView.bounds.width, collectionView.bounds.height - originalOriginY - viewHeight)
            containingViewContentSize = collectionView.contentSize
            updateFrame() { _ in }
        }
    }
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}