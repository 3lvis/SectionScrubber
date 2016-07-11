import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
}

public protocol SectionScrubberDataSource: class {
    func sectionScrubberContainerFrame(sectionScrubber: SectionScrubber) -> CGRect
}

public class SectionScrubber: UIView {
    enum VisibilityState {
        case Hidden
        case Visible
    }

    static let RightEdgeInset: CGFloat = 5.0

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
        if self.originalYOffset == nil {
            self.originalYOffset = self.collectionView?.bounds.origin.y ?? 0
        }
        self.containingViewFrame = self.dataSource?.sectionScrubberContainerFrame(self) ?? CGRectZero
        self.setScrubberFrame()
        self.updateFrame() { _ in }
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

    public func updateFrame(completion: ((indexPath: NSIndexPath?) -> Void)) {
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

        let centerPoint = CGPoint(x: self.center.x, y: self.center.y);
        let indexPath = collectionView.indexPathForItemAtPoint(centerPoint)
        completion(indexPath: indexPath)
    }

    func handleScrub(gestureRecognizer: UIGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        guard self.containingViewFrame.height != 0 else { return }

        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {
            let translation = panGestureRecognizer.translationInView(self)

            let y = translation.y
            let containerHeight = self.containingViewFrame.height - self.viewHeight
            var percentageInView = y / containerHeight

            if percentageInView < 0 {
                percentageInView = 0
            }

            if percentageInView > 1 {
                percentageInView = 1
            }

            let totalHeight = collectionView.contentSize.height - self.containingViewFrame.height
            let yOffset = (totalHeight * percentageInView)
            collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)

//            print("collectionView.contentSize.height: \(collectionView.contentSize.height)")
//            print("translation.y: \(translation.y)")
//            print("y: \(y)")
//            print("-")
//            print("containerHeight: \(containerHeight)")
//            print("-")
//            print("self.containingViewFrame.height: \(self.containingViewFrame.height)")
//            print("self.viewHeight: \(self.viewHeight)")
//            print("-")
//            print("percentageInView: \(percentageInView)")
//            print("-")
//            print("totalHeight: \(totalHeight)")
//            print("-")
//            print("yOffset: \(yOffset)")
//            print("()())()()()()()()()()()()()()()()()()()()")
//            print(" ")
        }
    }

    private func setSectionlabelFrame() {
        let rightOffset = self.sectionLabelState == .Visible ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        self.sectionLabel.frame = CGRectMake(self.frame.width - rightOffset - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func setScrubberFrame() {
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
