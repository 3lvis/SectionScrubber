//
//  UILabel+Sweetness.swift
//  Demo
//
//  Created by Marijn Schilling on 07/06/16.
//
//

import UIKit

public extension UILabel {
  
    public func width() -> CGFloat {
        let attributes = [NSFontAttributeName : self.font]
        let rect = (self.text ?? "" as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return rect.width
    }
}