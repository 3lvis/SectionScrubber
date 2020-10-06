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
        view.textAlignment = .center

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
        self.sectionLabelImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
        self.sectionLabelImageView.widthAnchor.constraint(equalTo: self.textLabel.widthAnchor, constant: 48).isActive = true
        self.sectionLabelImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        self.widthAnchor.constraint(equalTo: self.textLabel.widthAnchor).isActive = true
        self.textLabel.centerYAnchor.constraint(equalTo: self.sectionLabelImageView.centerYAnchor, constant: 1).isActive = true
        self.textLabel.centerXAnchor.constraint(equalTo: self.sectionLabelImageView.centerXAnchor, constant: -5).isActive = true
        self.textLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
        self.textLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        self.textLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
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
        // Source: https://github.com/bakkenbaeck/SweetUIKit/blob/master/Sources/UILabel%2BSweetness.swift
        let rect = (self.textLabel.attributedText ?? NSAttributedString()).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        self.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
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
