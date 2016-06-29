import UIKit

class PhotoCell: UICollectionViewCell {
    static let Identifier = "PhotoCellIdentifier"

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        backgroundColor = UIColor.blackColor()
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(photo: Photo) {
        imageView.image = photo.placeholder
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}
