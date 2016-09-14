import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(_ sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(_ sectionScrubber: SectionScrubber)
}

public protocol SectionScrubberDataSource: class {
    func sectionScrubber(_ sectionScrubber: SectionScrubber, titleForSectionAtIndexPath indexPath: IndexPath) -> String
}

public class SectionScrubber: UIView {
    private enum VisibilityState {
        case hidden
        case visible
    }

    private let thumbMargin: CGFloat = -60

    private let scrubberImageMargin: CGFloat = -6

    public weak var delegate: SectionScrubberDelegate?

    public weak var dataSource: SectionScrubberDataSource?

    private var adjustedContainerBoundsHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.bounds.height - (collectionView.contentInset.top + collectionView.contentInset.bottom + self.frame.height)
    }

    private var adjustedContainerOrigin: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        guard let window = collectionView.window else { return 0 }

        /*
         We check against the `UICollectionViewControllerWrapperView`, because this indicates we're working with
         a collection view that is inside a collection view controller. When that is the case, we have to deal with its 
         superview instead of with it directly, otherwise we have a offsetting problem.
         */
        if collectionView.superview?.isKind(of: NSClassFromString(String.init(format: "U%@ectionViewCont%@w", "IColl", "rollerWrapperVie"))!) != nil {
            return (collectionView.superview?.convert(collectionView.frame.origin, to: window).y)!
        } else {
            return collectionView.convert(collectionView.frame.origin, to: window).y
        }
    }

    private var adjustedContainerHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.contentSize.height - collectionView.bounds.height + (collectionView.contentInset.top + collectionView.contentInset.bottom)
    }

    private var adjustedContainerOffset: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.contentOffset.y + collectionView.contentInset.top
    }

    private var containingViewFrame: CGRect {
        return self.superview?.frame ?? CGRect.zero
    }

    private var scrubberWidth = CGFloat(26.0)

    private lazy var sectionLabel: SectionLabel = {
        let view = SectionLabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    fileprivate lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer()
    }()

    fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer()
    }()

    private weak var collectionView: UICollectionView?

    private var topConstraint: NSLayoutConstraint?

    private lazy var scrubberImageRightConstraint: NSLayoutConstraint = {
        return self.scrubberImageView.rightAnchor.constraint(equalTo: self.rightAnchor)
    }()

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
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return imageView
    }()

    public var scrubberImage: UIImage? {
        didSet {
            if let scrubberImage = self.scrubberImage {
                self.scrubberWidth = scrubberImage.size.width
                self.scrubberImageView.image = scrubberImage
                self.heightAnchor.constraint(equalToConstant: scrubberImage.size.height).isActive = true
                self.scrubberImageRightConstraint.isActive = true
                self.animateScrubberState(.hidden, animated: false)
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

    private var sectionLabelState = VisibilityState.hidden {
        didSet {
            if self.sectionLabelState != oldValue {
                if self.sectionLabelState == .visible { self.setSectionLabelActive() }
                if self.sectionLabelState == .hidden { self.setSectionLabelInactive() }
            }
        }
    }

    private var scrubberState = VisibilityState.hidden {
        didSet {
            if self.scrubberState != oldValue {
                self.updateSectionTitle()
                self.animateScrubberState(self.scrubberState, animated: true)
            }
        }
    }

    public init(collectionView: UICollectionView?) {
        self.collectionView = collectionView

        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.scrubberImageView)
        self.addSubview(self.sectionLabel)

        self.scrubberImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.sectionLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.sectionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.sectionLabel.rightAnchor.constraint(equalTo: self.scrubberImageView.leftAnchor, constant: self.thumbMargin).isActive = true

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
            self.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true

            self.topConstraint = self.topAnchor.constraint(equalTo: superview.topAnchor)
            self.topConstraint?.isActive = true
        }
    }

    private func userInteractionOnScrollViewDetected() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideScrubber), object: nil)
        self.perform(#selector(self.hideScrubber), with: nil, afterDelay: 2)

        if self.scrubberState == .hidden {
            self.scrubberState = .visible
        }
    }

    public func updateScrubberPosition() {
        guard let collectionView = self.collectionView else { return }
        guard collectionView.contentSize.height != 0 else { return }

        self.userInteractionOnScrollViewDetected()

        let percentage = self.boundedPercentage(collectionView.contentOffset.y / self.adjustedContainerHeight)
        let newY = self.adjustedContainerOffset + (self.adjustedContainerBoundsHeight * percentage)
        self.topConstraint?.constant = newY

        self.updateSectionTitle()
    }

    /**
     Initial dragging doesn't take in account collection view headers, just cells, so before the scrubber reaches
     a cell, this is not going to return an index path.
     **/
    private func indexPath(at point: CGPoint) -> IndexPath? {
        guard let collectionView = self.collectionView else { return nil }
        if let indexPath = collectionView.indexPathForItem(at: point) {
            return indexPath
        }
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader) {
            guard let view = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) else { continue }
            if view.frame.contains(point) {
                return indexPath
            }
        }
        return nil
    }

    private func updateSectionTitle() {
        // This makes too many assumptions about the collection view layout. 😔
        // It just uses 0, because it works for now, but we might need to come up with a better method for this.
        let centerPoint = CGPoint(x: 0, y: self.center.y);
        if let indexPath = self.indexPath(at: centerPoint) {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: indexPath) {
                self.updateSectionTitle(with: title)
            }
        } else if self.center.y < self.collectionView?.contentInset.top ?? 0 {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAtIndexPath: IndexPath.init(item: 0, section: 0)) {
                self.updateSectionTitle(with: title)
            }
        }
    }

    private func updateSectionTitle(with title: String) {
        self.sectionLabel.setText(title)
    }

    func handleScrub(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        guard let window = collectionView.window else { return }
        guard self.containingViewFrame.height != 0 else { return }
        self.sectionLabelState = gesture.state == .ended ? .hidden : .visible

        if gesture.state == .began || gesture.state == .changed || gesture.state == .ended {
            let locationInCollectionView = gesture.location(in: collectionView)
            let locationInWindow = collectionView.convert(locationInCollectionView, to: window)
            let location = locationInWindow.y - (self.adjustedContainerOrigin + collectionView.contentInset.top + collectionView.contentInset.bottom)

            let gesturePercentage = self.boundedPercentage(location / self.adjustedContainerBoundsHeight)
            let y = (self.adjustedContainerHeight * gesturePercentage) - collectionView.contentInset.top
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: y), animated: false)

            self.userInteractionOnScrollViewDetected()
        }
    }

    private func boundedPercentage(_ percentage: CGFloat) -> CGFloat {
        var newPercentage = percentage

        newPercentage = max(newPercentage, 0.0)
        newPercentage = min(newPercentage, 1.0)

        return newPercentage
    }

    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        self.sectionLabelState = gestureRecognizer.state == .ended ? .hidden : .visible
        self.userInteractionOnScrollViewDetected()
    }

    private func animateScrubberState(_ state: VisibilityState, animated: Bool) {
        let duration = animated ? 0.2 : 0.0
        switch state {
        case .visible:
            self.scrubberImageRightConstraint.constant = self.scrubberImageMargin
        case .hidden:
            self.scrubberImageRightConstraint.constant = self.scrubberImageView.image?.size.width ?? 0
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.layoutIfNeeded()
            }, completion: { success in })
    }

    private func setSectionLabelActive() {
        self.delegate?.sectionScrubberDidStartScrubbing(self)
        self.sectionLabel.show()
    }

    private func setSectionLabelInactive() {
        self.delegate?.sectionScrubberDidStopScrubbing(self)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideSectionLabel), object: nil)
        self.perform(#selector(hideSectionLabel), with: nil, afterDelay: 2)
    }

    func hideScrubber() {
        self.scrubberState = .hidden
    }

    func hideSectionLabel() {
        guard self.sectionLabelState != .visible else {
            return
        }
        self.sectionLabel.hide()
    }
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.longPressGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer {
            return true
        }

        return false
    }
}
