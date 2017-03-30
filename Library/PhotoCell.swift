import UIKit

class PhotoCell: UICollectionViewCell {
    static let Identifier = "PhotoCellIdentifier"

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill

        #if os(iOS)
            view.clipsToBounds = true
        #else
            view.clipsToBounds = false
            view.adjustsImageWhenAncestorFocused = true
        #endif

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.black
        self.addSubview(self.imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(_ photo: Photo) {
        self.imageView.image = photo.placeholder
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
}
