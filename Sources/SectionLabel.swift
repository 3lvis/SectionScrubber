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

    var labelImage: UIImage? {
        didSet {

            if let labelImage = self.labelImage {
                sectionLabelImageView.image = labelImage
                sectionLabelImageView.frame = self.bounds
                self.addSubview(sectionLabelImageView)
            }
        }
    }
}
