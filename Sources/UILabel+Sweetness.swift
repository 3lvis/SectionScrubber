import UIKit

extension UILabel {
func width() -> CGFloat {
        let attributes = [NSFontAttributeName : font]
        let rect = (text ?? "" as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return rect.width
    }
}