import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(sectionScrubber: SectionScrubber)
}

public protocol SectionScrubberDataSource: class {
    func sectionScrubber(sectionScrubber: SectionScrubber, titleForSectionAtIndexPath indexPath: NSIndexPath) -> String
}

public class SectionScrubber: UIView {
    private enum VisibilityState {
        case Hidden
        case Visible
    }

    public weak var delegate: SectionScrubberDelegate?

    public weak var dataSource: SectionScrubberDataSource?

    private var adjustedContainerBoundsHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom) - self.frame.size.height
    }

    private var adjustedContainerHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.contentSize.height - (collectionView.contentInset.bottom + collectionView.contentInset.top + self.adjustedContainerBoundsHeight)
    }

    private var adjustedContainerOffset: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.contentOffset.y + collectionView.contentInset.top
    }

    private var containingViewFrame: CGRect {
        return self.superview?.frame ?? CGRectZero
    }

    private var scrubberWidth = CGFloat(26.0)

    private lazy var sectionLabel: SectionLabel = {
        let view = SectionLabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer()
    }()

    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer()
    }()

    private weak var collectionView: UICollectionView?

    private var topConstraint: NSLayoutConstraint?

    public var sectionLabelImage: UIImage? {
        didSet {
            if let sectionLabelImage = self.sectionLabelImage {
                self.sectionLabel.labelImage = sectionLabelImage
            }
        }
    }

    private lazy var scrubberImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFit
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

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
            }
        }
    }

    private var scrubberState = VisibilityState.Hidden {
        didSet {
            if self.scrubberState != oldValue {
                self.updateSectionTitle()
                self.animateScrubberState(self.scrubberState, animated: true)
            }
        }
    }

    public init(collectionView: UICollectionView?) {
        self.collectionView = collectionView

        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.scrubberImageView)
        self.addSubview(self.sectionLabel)

        self.scrubberImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        self.scrubberImageView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -6).active = true

        self.sectionLabel.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        self.sectionLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        self.sectionLabel.rightAnchor.constraintEqualToAnchor(self.scrubberImageView.leftAnchor, constant: -60).active = true

        self.panGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.panGestureRecognizer.delegate = self
        self.scrubberImageView.addGestureRecognizer(self.panGestureRecognizer)

        self.longPressGestureRecognizer.addTarget(self, action: #selector(self.handleLongPress))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self
        self.scrubberImageView.addGestureRecognizer(self.longPressGestureRecognizer)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.animateScrubberState(self.scrubberState, animated: false)

        if let superview = self.superview {
            self.leftAnchor.constraintEqualToAnchor(superview.leftAnchor).active = true
            self.rightAnchor.constraintEqualToAnchor(superview.rightAnchor).active = true
            self.centerXAnchor.constraintEqualToAnchor(superview.centerXAnchor).active = true

            self.topConstraint = self.topAnchor.constraintEqualToAnchor(superview.topAnchor)
            self.topConstraint?.active = true
        }
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

        self.userInteractionOnScrollViewDetected()

        let percentage = collectionView.contentOffset.y / self.adjustedContainerHeight
        let newY = self.adjustedContainerOffset + (self.adjustedContainerBoundsHeight * percentage)
        self.topConstraint?.constant = newY

        self.updateSectionTitle()
    }

    /**
     Initial dragging doesn't take in account collection view headers, just cells, so before the scrubber reaches
     a cell, this is not going to return an index path.
     **/
    private func indexPath(at point: CGPoint) -> NSIndexPath? {
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(point) {
            return indexPath
        }
        return nil
    }

    private func updateSectionTitle() {
        //WARNING: this makes too many assumptions about the collection view layout. 😔
        // It just uses 0, because it works for now, but we might need to come up with a better method for this.
        let centerPoint = CGPoint(x: 0, y: self.center.y);
        if let indexPath = self.indexPath(at: centerPoint) {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                self.updateSectionTitle(with: title)
            }
        } else if self.center.y < self.collectionView?.contentInset.top ?? 0 {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: NSIndexPath.init(forItem: 0, inSection: 0)) {
                self.updateSectionTitle(with: title)
            }
        }
    }

    private func updateSectionTitle(with title: String) {
        self.sectionLabel.setText(title)
    }

    func handleScrub(gesture: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        guard self.containingViewFrame.height != 0 else { return }
        self.sectionLabelState = gesture.state == .Ended ? .Hidden : .Visible

        if gesture.state == .Began || gesture.state == .Changed || gesture.state == .Ended {
            let location = gesture.locationInView(self.window).y - collectionView.contentInset.top

            var gesturePercentage = location / self.adjustedContainerBoundsHeight
            // We want some leeway here, so we can go a bit further up/down, otherwise the scrubber feels a bit... locked?
            gesturePercentage = max(gesturePercentage, -0.01)
            gesturePercentage = min(gesturePercentage, 1.01)

            let y = (self.adjustedContainerHeight * gesturePercentage)
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: y), animated: false)
        }
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible
        self.userInteractionOnScrollViewDetected()
    }

    private func animateScrubberState(state: VisibilityState, animated: Bool) {
        let duration = animated ? 0.2 : 0.0
        UIView.animateWithDuration(duration, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: { }, completion: { success in })
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
        if gestureRecognizer == self.longPressGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer {
            return true
        }

        return false
    }
}
