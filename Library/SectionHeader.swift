import UIKit

class SectionHeader: UICollectionReusableView {
    static let Identifier = "SectionHeaderIdentifier"

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.frame = CGRect(x: 25, y: 20, width: self.frame.width, height: self.frame.height)
    }
}
