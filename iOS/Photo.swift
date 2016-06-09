import UIKit

struct Photo {
    enum Size {
        case Small, Large
    }

    var remoteID: String
    var placeholder = UIImage(named: "clear.png")!
    var url: String?
    static let NumberOfSections = 200

    init(remoteID: String) {
        self.remoteID = remoteID
    }

    func media(completion: (image: UIImage?, error: NSError?) -> ()) {
        completion(image: self.placeholder, error: nil)
    }

    static func constructRemoteElements() -> [String : [Photo]] {
        var sections = [String : [Photo]]()

        for section in 0..<Photo.NumberOfSections {
            var elements = [Photo]()
            for row in 0..<10 {
                var photo = Photo(remoteID: "\(section)-\(row)")

                let index = Int(arc4random_uniform(6))
                switch index {
                case 0:
                    photo.placeholder = UIImage(named: "0.jpg")!
                    break
                case 1:
                    photo.placeholder = UIImage(named: "1.jpg")!
                    break
                case 2:
                    photo.placeholder = UIImage(named: "2.jpg")!
                    break
                case 3:
                    photo.placeholder = UIImage(named: "3.jpg")!
                    break
                case 4:
                    photo.placeholder = UIImage(named: "4.jpg")!
                    break
                case 5:
                    photo.placeholder = UIImage(named: "5.png")!
                    photo.url = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4"
                default: break
                }
                elements.append(photo)
            }
            sections[Photo.title(index: section)] = elements
        }

        return sections
    }

    static func title(index index: Int) -> String {
        return "Section \(index)"
    }
}
