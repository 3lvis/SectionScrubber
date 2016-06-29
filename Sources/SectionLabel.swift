import UIKit

class SectionLabel: UIView {
    static let RightOffsetForActiveSectionLabel: CGFloat = 80.0
    static let RightOffsetForInactiveSectionLabel: CGFloat = 60.0

    private static let Margin : CGFloat = 19.0

    var sectionlabelWidth : CGFloat {
        return textLabel.width() + (2 * SectionLabel.Margin) + 4
    }

    private let sectionLabelImageView = UIImageView()

    private let textLabel = UILabel()

    var labelImage: UIImage? {
        didSet {
            if let labelImage = labelImage {
                sectionLabelImageView.image = labelImage
                addSubview(sectionLabelImageView)
                bringSubviewToFront(textLabel)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        hide()

        addSubview(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        sectionLabelImageView.frame = bounds
        textLabel.frame = CGRectMake(SectionLabel.Margin, SectionLabel.Margin, textLabel.width(), 22)
    }

    func setFont(font : UIFont){
         textLabel.font = font
    }

    func setTextColor(color : UIColor){
         textLabel.textColor = color
    }

    func setText(text: String){
        textLabel.text = text
        setNeedsLayout()
    }

    func hide() {
        UIView.animateWithDuration(0.2){
            self.alpha = 0
        }
    }

    func show(){
        UIView.animateWithDuration(0.2) {
            self.alpha = 1
        }
    }
}
