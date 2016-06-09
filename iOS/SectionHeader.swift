import UIKit

class SectionHeader: UICollectionReusableView {
    static let Identifier = "SectionHeaderIdentifier"

    lazy var titleLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.frame = CGRect(x: 10, y: 40, width: self.frame.width, height: self.frame.height)
    }

}
