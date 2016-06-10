import UIKit

class SectionLabel: UIView {
    static let RightOffsetForActiveSectionLabel: CGFloat = 80.0
    static let RightOffsetForInactiveSectionLabel: CGFloat = 60.0

    private static let Margin : CGFloat = 19.0

    var sectionlabelWidth : CGFloat {
        return self.textLabel.width() + (2 * SectionLabel.Margin) + 4
    }

    private let sectionLabelImageView = UIImageView()

    private let textLabel = UILabel()

    var labelImage: UIImage? {
        didSet {
            if let labelImage = self.labelImage {
                self.sectionLabelImageView.image = labelImage
                self.addSubview(sectionLabelImageView)
                self.bringSubviewToFront(self.textLabel)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.hide()

        self.addSubview(self.textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        self.sectionLabelImageView.frame = self.bounds
        self.textLabel.frame = CGRectMake(SectionLabel.Margin, SectionLabel.Margin, self.textLabel.width(), 22)
    }

    func setFont(font : UIFont){
         self.textLabel.font = font
    }

    func setTextColor(color : UIColor){
         self.textLabel.textColor = color
    }

    func setText(text: String){
        self.textLabel.text = text
        self.setNeedsLayout()
    }

    func hide() {
        UIView.animateWithDuration(0.2){
            self.alpha = 0
        }
    }

    func show(){

        guard textLabel.text != nil && textLabel.text != "" else { return }

        UIView.animateWithDuration(0.2) {
            self.alpha = 1
        }
    }
}
