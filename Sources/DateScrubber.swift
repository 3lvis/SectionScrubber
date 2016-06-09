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

    enum VisibilityState {
        case Hidden
        case Visible
    }

    static let RightEdgeInset: CGFloat = 5.0

    public var delegate : DateScrubberDelegate?

    public var viewHeight : CGFloat = 56.0

    public var scrubberWidth : CGFloat = 22.0

    public var containingViewFrame = UIScreen.mainScreen().bounds

    public var containingViewContentSize = UIScreen.mainScreen().bounds.size

    private var currentSectionTitle = ""

    private let scrubberImageView = UIImageView()

    private let sectionLabel = SectionLabel()

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

    private var sectionLabelState = VisibilityState.Hidden {
        didSet {

            if self.sectionLabelState == .Visible {self.setSectionLabelActive()}
            if self.sectionLabelState == .Hidden {self.setSectionLabelInactive()}
            self.updateSectionLabelFrame()
        }
    }

    private var scrubberState = VisibilityState.Hidden {
        didSet {
            self.updateDateScrubberFrame()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setSectionlabelFrame()
        self.view.addSubview(self.sectionLabel)

        self.dragGestureRecognizer.addTarget(self, action: #selector(handleDrag))
        self.scrubberImageView.userInteractionEnabled  = true
        self.scrubberImageView.addGestureRecognizer(self.dragGestureRecognizer)

        self.longPressGestureRecognizer.addTarget(self, action: #selector(handleLongPress))
        self.longPressGestureRecognizer.minimumPressDuration = 0.2
        self.longPressGestureRecognizer.cancelsTouchesInView = false
        self.longPressGestureRecognizer.delegate = self


        let scrubberGestureView = UIView(frame: CGRectMake(self.containingViewFrame.width-44,0,44,self.viewHeight))
        self.view.addSubview(scrubberGestureView)
        scrubberGestureView.addGestureRecognizer(self.longPressGestureRecognizer)
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

    private func userInteractionOnScrollViewDetected(){

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideScrubber), object: nil)
        self.performSelector(#selector(hideScrubber), withObject: nil, afterDelay: 3)

        if self.scrubberState == .Hidden {
            self.scrubberState = .Visible
        }
    }

    func calculateYPosInView(forYPosInContentView yPosInContentView: CGFloat) -> CGFloat{

        let percentageInContentView = yPosInContentView / containingViewContentSize.height
        return (containingViewFrame.height * percentageInContentView ) + containingViewFrame.minY
    }

    func calculateYPosInContentView(forYPosInView yPosInView: CGFloat) -> CGFloat {

        let percentageInView = (yPosInView - containingViewFrame.minY) / containingViewFrame.height
        return (containingViewContentSize.height * percentageInView) - containingViewFrame.minY
    }

    func handleLongPress(gestureRecognizer: UITapGestureRecognizer) {

        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible
    }

    func handleDrag(gestureRecognizer : UIPanGestureRecognizer) {

        self.sectionLabelState = gestureRecognizer.state == .Ended ? .Hidden : .Visible

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

        let rightOffset = self.sectionLabelState == .Visible ? SectionLabel.RightOffsetForActiveSectionLabel : SectionLabel.RightOffsetForInactiveSectionLabel
        self.sectionLabel.frame = CGRectMake(self.view.frame.width - rightOffset - self.sectionLabel.sectionlabelWidth, 0, self.sectionLabel.sectionlabelWidth, viewHeight)
    }

    private func setScrubberFrame(){
        switch self.scrubberState {
            case .Visible:
                scrubberImageView.frame = CGRectMake(self.containingViewFrame.width - self.scrubberWidth - DateScrubber.RightEdgeInset, 0, self.scrubberWidth, self.viewHeight)
            case .Hidden:
                scrubberImageView.frame = CGRectMake(self.containingViewFrame.width, 0, self.scrubberWidth, self.viewHeight)
        }
    }

    private func setSectionLabelActive(){

        self.sectionLabel.show()
    }

    private func setSectionLabelInactive() {
        self.performSelector(#selector(hideSectionLabel), withObject: nil, afterDelay: 3)
    }

    private func updateSectionLabelFrame() {

        UIView.animateWithDuration(0.2) {
            self.setSectionlabelFrame()
        }
    }

    private func updateDateScrubberFrame() {

        UIView.animateWithDuration(0.2){
            self.setScrubberFrame()
        }
    }

    func hideScrubber(){
        self.scrubberState = .Hidden
    }

    func hideSectionLabel(){
        self.sectionLabel.hide()
    }
}

extension DateScrubber : UIGestureRecognizerDelegate {
     public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}