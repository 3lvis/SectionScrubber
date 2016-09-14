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

        self.sectionLabelImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.sectionLabelImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
        self.sectionLabelImageView.widthAnchor.constraint(equalTo: self.textLabel.widthAnchor, constant: 48 ).isActive = true

        self.sectionLabelImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.widthAnchor.constraint(equalTo: self.textLabel.widthAnchor).isActive = true

        self.textLabel.centerYAnchor.constraint(equalTo: self.sectionLabelImageView.centerYAnchor, constant: 1.0).isActive = true
        self.textLabel.centerXAnchor.constraint(equalTo: self.sectionLabelImageView.centerXAnchor, constant: -2 ).isActive = true
        self.textLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true

        self.textLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        self.textLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFont(_ font : UIFont){
         self.textLabel.font = font
    }

    func setTextColor(_ color : UIColor){
         self.textLabel.textColor = color
    }

    func setText(_ text: String){
        self.textLabel.text = text
        self.widthAnchor.constraint(equalToConstant: self.textLabel.width())
    }

    func hide() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.alpha = 0
            }, completion: nil)
    }

    func show() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.alpha = 1
            }, completion: nil)
    }
}
