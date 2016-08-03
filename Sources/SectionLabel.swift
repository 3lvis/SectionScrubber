import UIKit

class SectionLabel: UIView {
    private lazy var sectionLabelImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    var labelImage: UIImage? {
        didSet {
            if let labelImage = self.labelImage {
                self.sectionLabelImageView.image = labelImage
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.hide()

        self.addSubview(self.sectionLabelImageView)
        self.addSubview(self.textLabel)

        self.sectionLabelImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        self.sectionLabelImageView.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 0.8).active = true
        self.sectionLabelImageView.widthAnchor.constraintEqualToAnchor(self.textLabel.widthAnchor, constant: 48 ).active = true

        self.sectionLabelImageView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true

        self.widthAnchor.constraintEqualToAnchor(self.textLabel.widthAnchor).active = true

        self.textLabel.centerYAnchor.constraintEqualToAnchor(self.sectionLabelImageView.centerYAnchor, constant: 1.0).active = true
        self.textLabel.centerXAnchor.constraintEqualToAnchor(self.sectionLabelImageView.centerXAnchor, constant: -2 ).active = true
        self.textLabel.heightAnchor.constraintEqualToAnchor(self.heightAnchor, multiplier: 0.8).active = true

        self.textLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        self.textLabel.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFont(font : UIFont){
         self.textLabel.font = font
    }

    func setTextColor(color : UIColor){
         self.textLabel.textColor = color
    }

    func setText(text: String){
        self.textLabel.text = text
        self.widthAnchor.constraintEqualToConstant(self.textLabel.width())
    }

    func hide() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.alpha = 0
            }, completion: nil)
    }

    func show() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.alpha = 1
            }, completion: nil)
    }
}
