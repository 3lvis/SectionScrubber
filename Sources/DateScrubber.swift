import UIKit

public protocol DateScrubberDelegate {

    func dateScrubber(dateScrubber:DateScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat)
}

public extension DateScrubberDelegate where Self: UICollectionViewController {

    func dateScrubber(dateScrubber:DateScrubber, didRequestToSetContentViewToYPosition yPosition: CGFloat){

        self.collectionView?.setContentOffset(CGPoint(x: 0,y: yPosition), animated: false)
    }
}

public class DateScrubber: UIViewController {

    enum State {
        case Inactive
        case Active
    }

    var sectionLabelState = State.Inactive {
        didSet {
            self.animateSectionlabelFrame()
        }
    }
    var scrubberState = State.Inactive {
        didSet {
            self.animateDateScrubberFrameToState(self.scrubberState)
        }
    }

    static let RightEdgeInset: CGFloat = 5.0

    public var delegate : DateScrubberDelegate?

    public var viewHeight : CGFloat = 56.0

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    private let scrubberImageView = UIImageView()

    private let sectionLabel = SectionLabel()

    private let dragGestureRecognizer = UIPanGestureRecognizer()
    private let longPressGestureRecognizer = UILongPressGestureRecognizer()

    private var timer : NSTimer?

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

                scrubberImageView.image = scrubberImage
                scrubberImageView.frame = CGRectMake(containingViewFrame.width, 0, scrubberImage.size.width, scrubberImage.size.height)
                self.view.addSubview(scrubberImageView)
            }
        }
    }

    public var font : UIFont? {
        didSet {
            if let font = self.font {
                sectionLabel.setFont(font)
            }
        }
    }

    public var textColor : UIColor? {
        didSet {
            if let textColor = self.textColor {
                sectionLabel.setTextColor(textColor)
            }
        }
    }

    private var viewIsBeingDragged = false {
        didSet{
            if self.viewIsBeingDragged {
              self.setSectionLabelActive()
            } else {

                self.setSectionLabelInactive()
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setSectionlabelFrame()
        self.view.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.dragGestureRecognizer
        self.scrubberImageView.userInteractionEnabled  = true
        self.scrubberImageView.addGestureRecognizer(self.dragGestureRecognizer)

        self.longPressGestureRecognizer.addTarget(self, action: #selector(handleLongPress))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self
        self.scrubberImageView.addGestureRecognizer(self.longPressGestureRecognizer)
    }

    public func updateFrame(scrollView scrollView: UIScrollView) {

        if self.scrubberState == .Inactive{
            self.scrubberState = .Active
        }

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hide), object: nil)
        self.performSelector(#selector(hide), withObject: nil, afterDelay: 3)

        if viewIsBeingDragged {
            return
        }

        let yPos = calculateYPosInView(forYPosInContentView: scrollView.contentOffset.y + containingViewFrame.minY)

        self.setFrame(atYpos: yPos)
    }

    public func updateSectionTitle(title : String){
        self.sectionLabel.setText(title)
        self.setSectionlabelFrame()
    }

    private func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height * percentageInContentView ) + containingViewFrame.minY
    }

    private func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleLongPress(gestureRecognizer: UITapGestureRecognizer) {

        if gestureRecognizer.state == .Began {
            self.setSectionLabelActive()
        }

        if gestureRecognizer.state == .Ended && !self.viewIsBeingDragged {
            self.setSectionLabelInactive()
        }
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        if self.viewIsBeingDragged != (gestureRecognizer.state != .Ended) {
            self.viewIsBeingDragged = gestureRecognizer.state != .Ended
        }

        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {

            let translation = gestureRecognizer.translationInView(self.view)
            var newYPosForDateScrubber =  self.view.frame.origin.y + translation.y


            if newYPosForDateScrubber < containingViewFrame.minY {
                newYPosForDateScrubber = containingViewFrame.minY
            }

            if newYPosForDateScrubber > containingViewFrame.height + containingViewFrame.minY - viewHeight {
                newYPosForDateScrubber = containingViewFrame.height + containingViewFrame.minY - viewHeight
            }

            self.setFrame(atYpos: newYPosForDateScrubber)

            let yPosInContentInContentView = calculateYPosInContentView(forYPosInView: newYPosForDateScrubber)
            self.delegate?.dateScrubber(self, didRequestToSetContentViewToYPosition: yPosInContentInContentView)

            gestureRecognizer.setTranslation(CGPoint(x: translation.x, y: 0), inView: self.view)
        }
    }

    private func setFrame(atYpos yPos: CGFloat){
        self.view.frame = CGRectMake(0, yPos, UIScreen.mainScreen().bounds.width, viewHeight)
    }

    private func setSectionlabelFrame(){
        let rightOffset = self.sectionLabelState == .Active ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        self.sectionLabel.frame = CGRectMake(self.view.frame.width - rightOffset - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func setSectionLabelActive(){

        if self.sectionLabelState == .Inactive {
            self.sectionLabelState = .Active
            self.sectionLabel.show()
        }
    }

    private func setSectionLabelInactive() {

        if self.sectionLabelState == .Active {
            self.sectionLabelState = .Inactive
        }
    }

    private func animateSectionlabelFrame() {

        UIView.animateWithDuration(0.2, animations: {
            self.setSectionlabelFrame()
        })
    }

    private func animateDateScrubberFrameToState(state: State) {

        var newScrubberFrame = self.scrubberImageView.frame
        newScrubberFrame.origin.x = state == .Active ? newScrubberFrame.origin.x - newScrubberFrame.width - DateScrubber.RightEdgeInset : newScrubberFrame.origin.x + newScrubberFrame.width + DateScrubber.RightEdgeInset

        UIView.animateWithDuration(0.2, animations: {
            self.scrubberImageView.frame = newScrubberFrame
        })
    }

    func hide(){
        self.sectionLabel.hide()
        self.scrubberState = .Inactive
    }
}

extension DateScrubber : UIGestureRecognizerDelegate {
     public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}