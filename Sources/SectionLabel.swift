//
//  SectionLabel.swift
//  Demo
//
//  Created by Marijn Schilling on 06/06/16.
//
//

import UIKit

class SectionLabel: UIView {

    let sectionLabelImageView = UIImageView()

    let textLabel = UILabel()

    var labelImage: UIImage? {
        didSet {

            if let labelImage = self.labelImage {
                sectionLabelImageView.image = labelImage
                sectionLabelImageView.frame = self.bounds
                self.addSubview(sectionLabelImageView)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func layoutSubviews() {
//          self.textLabel.frame = CGRectMake()
    }

    func setText(text: String){}

    func hide(){}

    func show(){}
}
