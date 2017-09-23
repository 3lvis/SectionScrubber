import UIKit

public protocol SectionScrubberDelegate: class {
    func sectionScrubberDidStartScrubbing(_ sectionScrubber: SectionScrubber)

    func sectionScrubberDidStopScrubbing(_ sectionScrubber: SectionScrubber)
}

public protocol SectionScrubberDataSource: class {
    func sectionScrubber(_ sectionScrubber: SectionScrubber, titleForSectionAt indexPath: IndexPath) -> String
}

public class SectionScrubber: UIView {
    public enum State {
        case hidden
        case scrolling
        case scrubbing
    }

    private let widthHiding: CGFloat = 4
    private let widthScrubbing: CGFloat = 200
    private let rightMarginHidden: CGFloat = 1

    #if os(iOS)
    private let leftMargin: CGFloat = 10
    private let height: CGFloat = 42
    private let widthScrolling: CGFloat = 140
    private let rightMarginScrolling: CGFloat = 1
    #else
    private let leftMargin: CGFloat = 20
    private let height: CGFloat = 100
    private let widthScrolling: CGFloat = 280
    private let rightMarginScrolling: CGFloat = -120
    #endif

    private let animationDuration: TimeInterval = 0.4
    private let animationDamping: CGFloat = 0.8
    private let animationSpringVelocity: CGFloat = 10

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

        if #available(iOS 11.0, *) {
            return collectionView.contentSize.height - collectionView.bounds.height + (collectionView.contentInset.top + collectionView.contentInset.bottom) - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
        } else {
            return collectionView.contentSize.height - collectionView.bounds.height + (collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
    }

    private var adjustedContainerOffset: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.contentOffset.y + collectionView.contentInset.top
    }

    private var containingViewFrame: CGRect {
        return self.superview?.frame ?? CGRect.zero
    }

    fileprivate lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer()
    }()

    fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer()
    }()

    private weak var collectionView: UICollectionView?

    private var topConstraint: NSLayoutConstraint?

    private lazy var sectionScrubberImageRightConstraint: NSLayoutConstraint = {
        self.sectionScrubberImageView.rightAnchor.constraint(equalTo: self.rightAnchor)
    }()

    private lazy var sectionScrubberWidthConstraint: NSLayoutConstraint = {
        self.sectionScrubberContainer.widthAnchor.constraint(equalToConstant: 4)
    }()

    private lazy var sectionScrubberRightConstraint: NSLayoutConstraint = {
        self.sectionScrubberContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 1)
    }()

    fileprivate lazy var sectionScrubberContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = true
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.backgroundColor = self.containerColor
        #if os(iOS)
            container.layer.cornerRadius = 4
        #else
            container.layer.cornerRadius = 12
        #endif
        container.layer.masksToBounds = true

        container.heightAnchor.constraint(equalToConstant: self.height).isActive = true

        return container
    }()

    fileprivate lazy var sectionScrubberImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "Arrows", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        return imageView
    }()

    public var state = State.hidden {
        didSet {
            if self.state != oldValue {
                self.updateSectionTitle()
                self.animateState(self.state, animated: true)
            }
        }
    }

    public var font: UIFont? {
        didSet {
            if let font = self.font {
                self.titleLabel.font = font
            }
        }
    }

    public var textColor: UIColor? {
        didSet {
            if let textColor = self.textColor {
                 self.titleLabel.textColor = textColor
            }
        }
    }

    public var containerColor: UIColor? {
        didSet {
            if let containerColor = self.containerColor {
                self.sectionScrubberContainer.backgroundColor = containerColor
            }
        }
    }

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = self.textColor
        label.font = self.font
        label.heightAnchor.constraint(equalToConstant: self.height).isActive = true

        return label
    }()

    public init(collectionView: UICollectionView?) {
        self.collectionView = collectionView

        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true

        self.panGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.panGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.panGestureRecognizer)

        self.longPressGestureRecognizer.addTarget(self, action: #selector(self.handleScrub))
        self.longPressGestureRecognizer.minimumPressDuration = 0.001
        self.longPressGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.longPressGestureRecognizer)

        self.addSubview(self.sectionScrubberContainer)
        self.sectionScrubberRightConstraint.isActive = true
        self.sectionScrubberContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.sectionScrubberWidthConstraint.isActive = true

        #if os(iOS)
            self.sectionScrubberContainer.addSubview(self.sectionScrubberImageView)
            self.sectionScrubberImageView.centerYAnchor.constraint(equalTo: self.sectionScrubberContainer.centerYAnchor).isActive = true
            self.sectionScrubberImageView.trailingAnchor.constraint(equalTo: self.sectionScrubberContainer.trailingAnchor, constant: -3).isActive = true
        #endif

        self.sectionScrubberContainer.addSubview(self.titleLabel)

        self.titleLabel.rightAnchor.constraint(equalTo: self.sectionScrubberContainer.rightAnchor).isActive = true
        self.titleLabel.leftAnchor.constraint(lessThanOrEqualTo: self.sectionScrubberContainer.leftAnchor, constant: self.leftMargin).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.sectionScrubberContainer.centerYAnchor).isActive = true

        self.backgroundColor = .red
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.animateState(self.state, animated: false)

        if let superview = self.superview {
            self.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            self.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true

            self.topConstraint = self.topAnchor.constraint(equalTo: superview.topAnchor)
            self.topConstraint?.isActive = true
        }
    }

    private func hideSectionScrubberAfterDelay() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideSectionScrubber), object: nil)
        self.perform(#selector(self.hideSectionScrubber), with: nil, afterDelay: 2)
    }

    public func updateScrubberPosition() {
        guard let collectionView = self.collectionView else { return }
        guard collectionView.contentSize.height != 0 else { return }

        if self.state == .hidden {
            self.state = .scrolling
        }
        self.hideSectionScrubberAfterDelay()

        let percentage = roundedPercentage(collectionView.contentOffset.y / self.adjustedContainerHeight)

        let newY = self.adjustedContainerOffset + (self.adjustedContainerBoundsHeight * percentage)
        if #available(iOS 11.0, *) {
            print("collectionView.adjustedContentInset " + String(describing: collectionView.adjustedContentInset))
            self.topConstraint?.constant = newY + collectionView.adjustedContentInset.top
        } else {
            self.topConstraint?.constant = newY
        }


        print("collectionView.contentOffset.y " + String(describing: collectionView.contentOffset.y))
        print("self.adjustedContainerHeight " + String(describing: self.adjustedContainerHeight))
        print("percentage " + String(describing: percentage))
        print("newY " + String(describing: newY))
        print(" ")
        print(" ")
        print(" ")
        print(" ")
        print(" ")
        print(" ")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateSectionTitle()
        }
    }

    /*
     * Only process touch events if we're hitting the actual sectionScrubber image.
     * Every other touch is ignored.
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let hitWidth: CGFloat = 60
        let hitFrame = CGRect(x: frame.width - hitWidth, y: 0, width: hitWidth, height: frame.height)

        if hitFrame.contains(point) {
            return super.hitTest(point, with: event)
        }

        return nil
    }

    /**
     Initial dragging doesn't take in account collection view headers, just cells, so before the sectionScrubber reaches
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
        var currentIndexPath: IndexPath?

        let centerIsAboveContentInset = self.center.y < self.collectionView?.contentInset.top ?? 0
        if centerIsAboveContentInset {
            currentIndexPath = IndexPath(item: 0, section: 0)
        } else {
            // Only will work on the Apple TV since iOS doesn't have a focused item.
            if let focusedCell = UIScreen.main.focusedView as? UICollectionViewCell, let indexPath = self.collectionView?.indexPath(for: focusedCell) {
                currentIndexPath = indexPath
            } else {
                // This makes too many assumptions about the collection view layout. It just uses CGPoint x: 0,
                // because it works for now, but we might need to come up with a better method for this.
                let centerPoint = CGPoint(x: 0, y: self.center.y)
                if let indexPath = self.indexPath(at: centerPoint) {
                    currentIndexPath = indexPath
                } else {
                    let elements = self.collectionView?.collectionViewLayout.layoutAttributesForElements(in: self.frame)?.flatMap { $0.indexPath } ?? [IndexPath]()
                    if let indexPath = elements.last {
                        currentIndexPath = indexPath
                    }
                }
            }
        }

        if let currentIndexPath = currentIndexPath {
            if let title = self.dataSource?.sectionScrubber(self, titleForSectionAt: currentIndexPath) {
                self.titleLabel.text = title.uppercased()
            }
        }
    }

    private var previousLocation: CGFloat = 0

    @objc func handleScrub(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        guard let window = collectionView.window else { return }
        guard self.containingViewFrame.height != 0 else { return }

        if gesture.state == .began {
            self.startScrubbing()
        }

        if gesture.state == .began || gesture.state == .changed || gesture.state == .ended {
            let locationInCollectionView = gesture.location(in: collectionView)
            let locationInWindow = collectionView.convert(locationInCollectionView, to: window)
            let location = locationInWindow.y - (self.adjustedContainerOrigin + collectionView.contentInset.top + collectionView.contentInset.bottom)

            if gesture.state != .began && location != self.previousLocation {
                let gesturePercentage = self.roundedPercentage(location / self.adjustedContainerBoundsHeight)
                let y = (self.adjustedContainerHeight * gesturePercentage) - collectionView.contentInset.top
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: y), animated: false)
            }

            self.previousLocation = location
            self.hideSectionScrubberAfterDelay()
        }

        if gesture.state == .ended || gesture.state == .cancelled {
            self.stopScrubbing()
        }
    }

    private func roundedPercentage(_ percentage: CGFloat) -> CGFloat {
        var newPercentage = percentage

        newPercentage = max(newPercentage, 0.0)
        newPercentage = min(newPercentage, 1.0)

        return newPercentage
    }

    private func animateState(_ state: State, animated: Bool) {
        let duration = animated ? self.animationDuration : 0.0
        var titleAlpha: CGFloat = 1

        switch state {
        case .hidden:
            self.sectionScrubberRightConstraint.constant = self.rightMarginHidden
            self.sectionScrubberWidthConstraint.constant = self.widthHiding
            titleAlpha = 0
        case .scrolling:
            self.sectionScrubberRightConstraint.constant = self.rightMarginScrolling
            self.sectionScrubberWidthConstraint.constant = self.widthScrolling
        case .scrubbing:
            self.sectionScrubberRightConstraint.constant = self.rightMarginHidden
            self.sectionScrubberWidthConstraint.constant = self.widthScrubbing
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: self.animationDamping, initialSpringVelocity: self.animationSpringVelocity, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut], animations: {
            self.titleLabel.alpha = titleAlpha
            let isIPhone5OrBelow = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) <= 568.0
            if isIPhone5OrBelow {
                self.sectionScrubberContainer.layoutIfNeeded()
            } else {
                self.layoutIfNeeded()
            }
        }, completion: { _ in })
    }

    private func startScrubbing() {
        self.delegate?.sectionScrubberDidStartScrubbing(self)
        self.state = .scrubbing
    }

    private func stopScrubbing() {
        self.delegate?.sectionScrubberDidStopScrubbing(self)

        guard self.state == .scrubbing else {
            return
        }

        self.state = .scrolling
    }

    @objc func hideSectionScrubber() {
        self.state = .hidden
    }
}

extension SectionScrubber: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.view != self || otherGestureRecognizer.view == self {
            return false
        }
        
        return true
    }
}
