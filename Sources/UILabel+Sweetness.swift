import UIKit

extension UILabel {
func width() -> CGFloat {
        let attributes = [NSFontAttributeName : self.font]
        let rect = (self.text ?? ("" as NSString) as String).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return rect.width
    }
}
